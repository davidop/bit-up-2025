param location string
param vnetName string
param vnetAddressPrefixes array
param subnetArray array
param enableDdosProtection bool
param enableVmProtection bool
param hasPeering  bool
param remoteVnetName string
param remoteRGVnetName string
param allowVirtualNetworkAccess bool 
param allowForwardedTraffic bool     
param allowGatewayTransit bool
param useRemoteGateways bool
         
//Monitoring
param mngResourceGroupName string
param logAnalyticsNetWatchName string
param storageNetWatchName string
param networkWatcherName string

var specialSubnet = [
  'GatewaySubnet'
  'AzureBastionSubnet'
  'AzureFirewallSubnet'
]

param routingTableName  string
param routes array

resource rscNSG 'Microsoft.Network/networkSecurityGroups@2022-11-01' = [for (subnet, i) in subnetArray: if (!contains(specialSubnet, subnet.subnetName)) {
  name: subnet.NSGName
  location: location
  properties: contains(subnet,'properties') ? subnet.properties : {}
}]

/*module modNetworkWatcherFlowLog 'networkwatcher-flowlog-template.bicep' = [for (subnet, i) in subnetArray: if (!contains(specialSubnet, subnet.subnetName)) {
  name: 'flowlog-${uniqueString(subnet.NSGName)}-deployment'
  params: {
    location: location
    logAnalyticsWSName: logAnalyticsNetWatchName
    nsgName: subnet.NSGName
    mngResourceGroupName: mngResourceGroupName
    nsgResourceGroupName: resourceGroup().name
    storageAccontName: storageNetWatchName
    networkWatcharName: networkWatcherName
  }
}]*/

@batchSize(1)
module modNetworkWatcherFlowLog 'networkwatcher-flowlog2-template.bicep' = [for (subnet, i) in subnetArray: if (!contains(specialSubnet, subnet.subnetName)) {
  name: 'flowlog-${uniqueString(subnet.NSGName)}-deployment'
  params: {
    location: location
    logAnalyticsWSName: logAnalyticsNetWatchName
    vnetName: vnetName
    mngResourceGroupName: mngResourceGroupName
    vnetResourceGroupName: resourceGroup().name
    storageAccountName: storageNetWatchName
    networkWatcherName: networkWatcherName
  }
}]

resource rscRouteTable 'Microsoft.Network/routeTables@2022-11-01' = {
  name: routingTableName
  location: location
  properties: {
    disableBgpRoutePropagation: true
    routes: [for (route, i) in routes: {
      name: route.name
      properties: route.properties
    }]
  }
}

resource rscRemoteVnet 'Microsoft.Network/virtualNetworks@2022-11-01' existing = {
  name: remoteVnetName
  scope: resourceGroup(remoteRGVnetName)
}


resource rscVnet 'Microsoft.Network/virtualNetworks@2022-11-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: vnetAddressPrefixes
    }
    subnets: [for (subnet, i) in subnetArray: {
        name: subnet.subnetName
        properties: {
          addressPrefix: subnet.subnetAddressPrefix
          routeTable: {
            id: rscRouteTable.id
          }
          networkSecurityGroup: contains(specialSubnet, subnet.subnetName) ? null : {
            id : contains(specialSubnet, subnet.subnetName) ? null : rscNSG[i].id
          }
          delegations: subnet.delegations
        }
      }]
    enableDdosProtection: enableDdosProtection
    enableVmProtection: enableVmProtection
  }
}

module modPeeringFromLocalToRemote 'peering-template.bicep' = if (hasPeering) {
  name: 'peeringFromLocalToRemote-deployment'
  scope: resourceGroup(resourceGroup().name)
  params: {
    vnetName: rscVnet.name
    remoteVnetId: rscRemoteVnet.id
    allowVirtualNetworkAccess: allowVirtualNetworkAccess
    allowForwardedTraffic: allowForwardedTraffic
    allowGatewayTransit: allowGatewayTransit
    useRemoteGateways: useRemoteGateways
  }
}

module modPeeringFromRemoteToLocal 'peering-template.bicep' = if (hasPeering) {
  name: 'peeringFromRemoteToLocal-deployment'
  scope: resourceGroup(remoteRGVnetName)
  params: {
    vnetName: remoteVnetName
    remoteVnetId: rscVnet.id
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    useRemoteGateways: false
  }
  dependsOn: [
    modPeeringFromLocalToRemote
  ]
}

output subnetDeployed array = [for (subnet, i) in subnetArray: {
  subnetName: subnet.subnetName
  resourceId: rscVnet.properties.subnets[i].id
}]
