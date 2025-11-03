param location string
param mngResourceGroupName string 
param vnetName string
param vnetResourceGroupName string
param storageAccountName string
param logAnalyticsWSName string
param networkWatcherName string 

var trafficAnalyticsInterval = 60
var retentionDays = 30
var flowLogVersion = 2

resource rscVnet 'Microsoft.Network/virtualNetworks@2023-04-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetResourceGroupName)
}

module modFlowLogResources 'loganalytics-networkwatcher-template.bicep' = {
  name: 'flowlogresources-${uniqueString(vnetName)}'
  scope: resourceGroup(mngResourceGroupName)
  params: {
    location: location
    logAnalyticsWSName: logAnalyticsWSName
  }
}

module modFlowLogStgAccount 'stgaccount-networkwatcher-template.bicep' = {
  name: 'stgaccount-networkwatcher-deployment'
  scope: resourceGroup(mngResourceGroupName)
  params: {
    location: location
    storageAccountName: storageAccountName
  }
}


// Módulo que crea el Flow Log (en el RG del Network Watcher)
module modFlowLog 'flowlog-template.bicep' = {
  name: 'deployFlowLog'
  scope: resourceGroup(mngResourceGroupName)
  params: {
    location: location
    networkWatcherName: networkWatcherName
    vnetId: rscVnet.id
    storageId: modFlowLogStgAccount.outputs.rscStgAccountId
    logAnalyticsWSId: modFlowLogResources.outputs.rscLogAnalyticsWSid
    flowLogVersion: flowLogVersion
    retentionDays: retentionDays
    trafficAnalyticsInterval: trafficAnalyticsInterval
  }
}
