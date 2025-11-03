param location string
param mgmtPublicIpAddressName string
param azureFirewallName string
param vnetName string
param zones array
param publicIpAddressArray array
param azureFirewallTier string
param natRuleList array
param networkRuleList array
param appRuleList array

//Monitoring
param enableMonitoring bool = false
param fwSettingDiagName string = ''
param publicIPAddressSettingDiagName string = ''
param logAnalyticsWSid string = ''


resource rscMgmtFWPublicIp 'Microsoft.Network/publicIPAddresses@2022-11-01' = {
  name:mgmtPublicIpAddressName
  location: location
  sku: {
    name: 'Standard'
  }
  zones: zones
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource rscFWPublicIp 'Microsoft.Network/publicIPAddresses@2022-11-01' = [for (publicIpAddress, i) in publicIpAddressArray: {
  name:publicIpAddress.name
  location: location
  sku: {
    name: 'Standard'
  }
  zones: zones
  properties: {
    publicIPAllocationMethod: publicIpAddress.allocationMethod
    ddosSettings: {
      protectionMode: publicIpAddress.protectionMode
    }
  }
}]

resource rscVnet 'Microsoft.Network/virtualNetworks@2022-11-01' existing = {
  name: vnetName
}

resource rscAFWSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-11-01' existing = {
  parent: rscVnet
  name: 'AzureFirewallSubnet'
}

resource rscAFWMGMTSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-11-01' existing = {
  parent: rscVnet
  name: 'AzureFirewallManagementSubnet'
}

var azureFirewallIpConfigurations = [for i in range(0, length(publicIpAddressArray)): {
  name: 'IpConf${(i + 1)}'
  properties: {
    subnet: ((i == 0) ? json('{"id": "${rscAFWSubnet.id}"}') : 'null')
    publicIPAddress: {
      id: rscFWPublicIp[i].id
    }
  }
}]

resource rscFirewall 'Microsoft.Network/azureFirewalls@2022-11-01' = {
  name: azureFirewallName
  location: location
  zones: zones
  properties: {
    ipConfigurations: azureFirewallIpConfigurations
    natRuleCollections: [ for natRule in natRuleList:{
      name: natRule.name
      properties: {
        action: {
          type: natRule.action
        }
        priority: natRule.priority
        rules: natRule.rules
      }
    }]
    networkRuleCollections: [for networkRule in networkRuleList:{
      name: networkRule.name
      properties: {
        action: {
          type: networkRule.action
        }
        priority: networkRule.priority
        rules: networkRule.rules
      }
    }]
    applicationRuleCollections: [for appRule in appRuleList:{
      name: appRule.name
      properties: {
        action: {
          type: appRule.action
        }
        priority: appRule.priority
        rules: appRule.rules
      }
    }]
    sku:  {
      tier: azureFirewallTier
    }
    managementIpConfiguration: {
      name: rscMgmtFWPublicIp.name
      properties: {
        subnet: {
          id: rscAFWMGMTSubnet.id
        }
        publicIPAddress: {
          id: rscMgmtFWPublicIp.id
        }
      }
    }
  }
}

resource rscFirewallDiagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if(enableMonitoring) {
  name: fwSettingDiagName
  scope: rscFirewall
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

resource rscMgmtFWPiPDiagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if(enableMonitoring) {
  name: publicIPAddressSettingDiagName
  scope: rscMgmtFWPublicIp
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

resource rscFWPiPDiagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for (publicIpAddress, i) in publicIpAddressArray: if(enableMonitoring) {
  name: publicIPAddressSettingDiagName
  scope: rscFWPublicIp[i]
  properties: {
    workspaceId: logAnalyticsWSid
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
  }
}]
