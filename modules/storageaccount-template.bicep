param storageAccountName string
param location string
param publicNetworkAccess string = 'Enabled'
param enableAllNetworks bool = false

var networkAclsRules = {
  bypass: 'AzureServices'
  defaultAction: 'Deny'
}

var networkAclsRulesAllNetworks = {
  resourceAccessRules: []
  bypass: 'AzureServices'
  virtualNetworkRules: []
  ipRules: []
  defaultAction: 'Allow'
}


resource rscStrAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    publicNetworkAccess: publicNetworkAccess
    networkAcls: (publicNetworkAccess=='Enabled' && !enableAllNetworks) ? networkAclsRules : ((publicNetworkAccess=='Enabled' && enableAllNetworks) ? networkAclsRulesAllNetworks : null)
    //allowSharedKeyAccess: false
    //allowBlobPublicAccess: false
    defaultToOAuthAuthentication: true
  }
}

output rscStrAccountId string = rscStrAccount.id
