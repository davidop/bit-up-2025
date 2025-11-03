param location string             = resourceGroup().location
param logAnalyticsWSName string   = ''
param tags object                 = {}

var logAnalyticsSku               = 'PerGB2018'

resource rscLogAnalyticsWS 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsWSName
  location: location
  tags: tags
  properties: {
    sku: {
      name: logAnalyticsSku
    }
  }
}

output rscLogAnalyticsWSid string = rscLogAnalyticsWS.id
