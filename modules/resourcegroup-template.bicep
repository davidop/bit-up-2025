targetScope = 'subscription'

param resourceGroupName string
param location string

resource rscNetworkResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
}

output rscNetworkResourceGroupId string = rscNetworkResourceGroup.id
