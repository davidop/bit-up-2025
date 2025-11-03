param privateDNSZones array

resource rscPrivateDNSZone 'Microsoft.Network/privateDnsZones@2020-06-01' = [for privateDNSZoneName in privateDNSZones: {
  name: privateDNSZoneName
  location: 'global'
}]

output privateDNSZone array = [ for (privateDNSZoneName, i) in privateDNSZones: {
  privateDNSZoneName: privateDNSZoneName
  resourceId: rscPrivateDNSZone[i].id
}]
