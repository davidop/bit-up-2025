param location string
param networkWatcherName string
param vnetId string
param storageId string
param logAnalyticsWSId string
param flowLogVersion int
param retentionDays int
param trafficAnalyticsInterval int

var vnetNameFromId = split(vnetId, '/')[length(split(vnetId, '/')) - 1]

resource rscNetworkWatcher 'Microsoft.Network/networkWatchers@2023-04-01' existing = {
  name: networkWatcherName
}

resource rscFlowLog 'Microsoft.Network/networkWatchers/flowLogs@2023-09-01' = {
  parent: rscNetworkWatcher
  name: '${vnetNameFromId}-flowlog'
  location: location
  properties: {
    targetResourceId: vnetId
    storageId: storageId
    enabled: true
    format: {
      type: 'JSON'
      version: flowLogVersion
    }
    flowAnalyticsConfiguration: {
      networkWatcherFlowAnalyticsConfiguration: {
        enabled: true
        workspaceResourceId: logAnalyticsWSId
        trafficAnalyticsInterval: trafficAnalyticsInterval
      }
    }
    retentionPolicy: {
      days: retentionDays
      enabled: true
    }
  }
}
