param location string

param webAppName string
param containerImage string
param appServicePlanName string
param vnetName string
param subnetName string

//monitoring
param enableMonitoring bool
param settingDiagName string
param logAnalyticsWSid string

resource rscVnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: vnetName
}

resource rscSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = {
  name: subnetName
  parent: rscVnet
}

resource rscAppServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'B1'
    tier: 'Basic'
    size: 'B1'
    capacity: 1
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

resource rscWebApp 'Microsoft.Web/sites@2022-03-01' = {
  name: webAppName
  location: location
  kind: 'app,linux,container'
  properties: {
    serverFarmId: rscAppServicePlan.id
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerImage}'
      appSettings: [
        {
          name: 'WEBSITES_PORT'
          value: '3000'
        }
      ]
      alwaysOn: true
    }
    httpsOnly: true
  }
}

resource rscVnetIntegration 'Microsoft.Web/sites/networkConfig@2022-03-01' = {
  name: '${webAppName}/virtualNetwork'
  properties: {
    subnetResourceId: rscSubnet.id
  }
  dependsOn: [
    rscWebApp
  ]
}

resource webAppDiagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if(enableMonitoring) {
  name: settingDiagName
  scope: rscWebApp
  properties: {
    workspaceId: logAnalyticsWSid
    logs: [
      {
        categoryGroup: 'AllLogs'
        enabled: true
      }
    ]
  }
}

output webAppUrl string = 'https://${webAppName}.azurewebsites.net'
output rscWebAppId string = rscWebApp.id
