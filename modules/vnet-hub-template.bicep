param location string = resourceGroup().location
param vnetName string
param vnetAddressPrefixes array
param subnetArray array
param enableDdosProtection bool
param enableVmProtection bool

//Monitoring
param mngResourceGroupName string
param logAnalyticsNetWatchName string
param storageNetWatchName string
param networkWatcherName string

var specialSubnet = [
  'GatewaySubnet'
  'AzureBastionSubnet'
  'AzureFirewallSubnet'
  'AzureFirewallManagementSubnet'
]

resource rscNSG 'Microsoft.Network/networkSecurityGroups@2022-11-01' = [for (subnet, i) in subnetArray: if (!contains(specialSubnet, subnet.subnetName)) {
  name: 'nsg-${subnet.subnetName}'
  location: location
  properties: {}
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

resource rscRouteTable 'Microsoft.Network/routeTables@2022-11-01' = [for (subnet, i) in subnetArray: if (!(empty(subnet.routeTableName))){
  name: 'rt-${subnet.routeTableName}'
  location: location
  properties: {
    disableBgpRoutePropagation: (!contains('GatewaySubnet', subnet.subnetName))//true
    routes: subnet.routes
  }
}]

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
          routeTable: (empty(subnet.routeTableName)) ? null : {
            id: rscRouteTable[i].id
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

output subnetDeployed array = [for (subnet, i) in subnetArray: {
  subnetName: subnet.subnetName
  resourceId: rscVnet.properties.subnets[i].id
}]

output rscVNetId string = rscVnet.id 
