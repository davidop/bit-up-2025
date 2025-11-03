
param privateDnsZoneName string
param vnetName string
param vnetResourceGroupName string
param registrationEnabled bool = false


resource rscPrivateDnsZones 'Microsoft.Network/privateDnsZones@2024-06-01' existing = {
  name: privateDnsZoneName
}

resource rscVnet 'Microsoft.Network/virtualNetworks@2022-11-01' existing = {
  scope: resourceGroup(vnetResourceGroupName)
  name: vnetName
}

resource rscVirtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  parent: rscPrivateDnsZones
  name: '${privateDnsZoneName}-${vnetName}'
  location: 'global'
  properties: {
    registrationEnabled: registrationEnabled
    virtualNetwork: {
      id: rscVnet.id
    }
  }
}
