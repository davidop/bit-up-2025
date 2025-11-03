param location string
param publicIPAddressName string
param zones array
param publicIpAddressProtect string

//monitoring
param enableMonitoring bool
param publicIPSettingDiagName string
param logAnalyticsWSid string

resource rscAppGwPublicIp 'Microsoft.Network/publicIPAddresses@2022-11-01' = {
  name: publicIPAddressName
  location: location
  sku: {
    name: 'Standard'
  }
  zones: zones
  properties: {
    publicIPAllocationMethod: 'Static'
    ddosSettings: {
      protectionMode: publicIpAddressProtect
    }
  }
}

resource publicIpAddressDiagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if(enableMonitoring) {
  name: publicIPSettingDiagName
  scope: rscAppGwPublicIp
  properties: {
    workspaceId: logAnalyticsWSid
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
  }
}

output rscAppGwPublicIpId string = rscAppGwPublicIp.id
