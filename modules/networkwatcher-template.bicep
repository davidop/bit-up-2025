param location string             
param networkWatcharName string

resource rscNetworkWatcher 'Microsoft.Network/networkWatchers@2023-04-01' = {
  name: networkWatcharName
  location: location
}
