param location string
param mngResourceGroupName string 
param nsgName string
param nsgResourceGroupName string
param storageAccontName string
param logAnalyticsWSName string
param networkWatcharName string   = 'NetworkWatcher_${location}'

var trafficAnalyticsInterval      = 60
var retentionDays                 = 30
var flowLogVersion                = 2

resource rscNsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' existing = {
  name: nsgName
}

module modFlowLogResources 'loganalytics-networkwatcher-template.bicep' = {
  name: 'flowlogresources-${uniqueString(nsgName)}-deployment'
  scope: resourceGroup(mngResourceGroupName)
  params: {
    location: location
    logAnalyticsWSName: logAnalyticsWSName
  }
}

resource rscStrAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccontName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  /*properties: {
    publicNetworkAccess: 'Enabled'
  }*/
}

resource rscNetworkWatcher 'Microsoft.Network/networkWatchers@2023-04-01' = {
  name: networkWatcharName
  location: location
}

resource rscFlowLog 'Microsoft.Network/networkWatchers/flowLogs@2023-04-01' = {
  parent: rscNetworkWatcher
  name: '${nsgName}-${nsgResourceGroupName}'
  location: location
  properties: {
    targetResourceId: rscNsg.id
    storageId: rscStrAccount.id
    enabled: true
    format: {
      type: 'JSON'
      version: flowLogVersion
    }
    flowAnalyticsConfiguration: {
      networkWatcherFlowAnalyticsConfiguration:{
        enabled: true
        workspaceResourceId: modFlowLogResources.outputs.rscLogAnalyticsWSid
        trafficAnalyticsInterval: trafficAnalyticsInterval
      }
    }
    retentionPolicy: {
      days: retentionDays
      enabled: true
    }
  }
}
