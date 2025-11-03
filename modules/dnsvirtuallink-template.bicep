param vnetId string
param vnetName string
param privateDnsZoneName string
param registrationEnabled bool = true
param vnetHubName string
param vnetHubResourceGroup string

resource rscPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: privateDnsZoneName
}

resource rscVirtualNetworkLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: rscPrivateDnsZone
  name: '${privateDnsZoneName}-${vnetName}'
  location: 'global'
  properties: {
    registrationEnabled: registrationEnabled
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource rscVirtualNetworkLinksToHub 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: rscPrivateDnsZone
  name: '${privateDnsZoneName}-${vnetHubName}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: resourceId(vnetHubResourceGroup,'Microsoft.Network/virtualNetworks',vnetHubName)
    }
  }
}

output privateDnsZoneId string = rscPrivateDnsZone.id


