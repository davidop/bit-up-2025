targetScope = 'resourceGroup'

param location string
param storagePrefix string

// Nota: storage account names deben ser lowercase 3-24 chars y globalmente únicos.
var saName = toLower('${storagePrefix}st')

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: saName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {}
}

output storageAccountName string = storageAccount.name
output storageAccountId string = storageAccount.id
