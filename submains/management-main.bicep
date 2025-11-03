targetScope = 'resourceGroup'

param location string

param connectStorageNetWatchName string
param juiceShopStgNetWatchName string
param connectSettingDiaglogAnalyticsWSName string
param juiceShopSettingDiaglogAnalyticsWSName string
param networkWatcherName string


module modConnNetworkWatcherStorageAccount '../modules/storageaccount-template.bicep'= {
  name: 'connectnetworkwatcherstorageaccount-deployment'
  params: {
    location: location
    storageAccountName: connectStorageNetWatchName
    publicNetworkAccess: 'Enabled'
  }
}
module modJuiceShopNetworkWatcherStorageAccount '../modules/storageaccount-template.bicep'= {
  name: 'juiceshopnetworkwatcherstorageaccount-deployment'
  params: {
    location: location
    storageAccountName: juiceShopStgNetWatchName
    publicNetworkAccess: 'Enabled'
  }
}

module modNetworkWatcher '../modules/networkwatcher-template.bicep' = {
  name: 'networkWatcher-deployment'
  params: {
    location: location
    networkWatcharName: networkWatcherName
  }
}

module modConnectLogAnalyticsDiag '../modules/loganalytics-diag-template.bicep' = {
  name: 'connectloganalyticsdiag-deployment'
  params: {
    location: location
    logAnalyticsWSName: connectSettingDiaglogAnalyticsWSName
  }
}

module modJuiceShopLogAnalyticsDiag '../modules/loganalytics-diag-template.bicep' = {
  name: 'juiceshoploganalyticsdiag-deployment'
  params: {
    location: location
    logAnalyticsWSName: juiceShopSettingDiaglogAnalyticsWSName
  }
}
