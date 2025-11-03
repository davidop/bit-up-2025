
param location string
param storageAccountName string

resource rscStgAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

output rscStgAccountId string = rscStgAccount.id
