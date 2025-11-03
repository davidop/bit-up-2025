param location string
param customNetworkInterfaceName string 
param privateEndpointName string 
param vnetName string
param vnetHubName string
param vnetHubResourceGroup string
param privateZoneDNSName string
param privateEndpointSubnetName string
param privateLinkServiceId string
param groupIds array
param privateIPAddress string = ''
param registrationEnabled bool = true
param privateDNSZoneGroup string


module modDNSResourceGroup 'resourcegroup-template.bicep' = {
  scope: subscription(subscription().subscriptionId)
  name: 'dnsresourcegroup-deployment'
  params: {
    location: location
    resourceGroupName: privateDNSZoneGroup
  }
}

module modPrivateDNSZone 'azprivatedns-template.bicep' = {
  name: 'privatednszones-deployment'  
  scope: resourceGroup(privateDNSZoneGroup)
  params: {
    privateDNSZones: [privateZoneDNSName]
  }
  dependsOn: [
    modDNSResourceGroup
  ]
}

resource rscPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-08-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, privateEndpointSubnetName)
    }
    customNetworkInterfaceName: customNetworkInterfaceName
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: privateLinkServiceId
          groupIds: groupIds
        }
      }
    ]
    ipConfigurations: empty(privateIPAddress) ? [] : [
      {
        name: 'ipconfig1'
        properties: {
          groupId: length(groupIds) > 0 ? groupIds[0] : ''
          memberName: 'nic0'
          privateIPAddress: privateIPAddress
        }
      } 
    ]
  }
  dependsOn: [
    modPrivateDNSZone
  ]
}

resource rscPvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-12-01' = {
  parent: rscPrivateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: modDNSResources.outputs.privateDnsZoneId
        }
      }
    ]
  }
}

resource rscVnet 'Microsoft.Network/virtualNetworks@2022-11-01' existing = {
  name: vnetName
}

resource rscVnetHub 'Microsoft.Network/virtualNetworks@2022-11-01' existing = {
  name: vnetHubName
}

module modDNSResources 'dnsvirtuallink-template.bicep' = {
  name: 'dnsresources${uniqueString(privateEndpointName)}-deployment'
  scope: resourceGroup(privateDNSZoneGroup)
  params: {
    registrationEnabled: registrationEnabled
    vnetName: rscVnet.name
    vnetId: rscVnet.id
    vnetHubResourceGroup: vnetHubResourceGroup
    vnetHubName: rscVnetHub.name
    privateDnsZoneName: privateZoneDNSName
  }
  dependsOn: [
    rscPrivateEndpoint
  ]
}


