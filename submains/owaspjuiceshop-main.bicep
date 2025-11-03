targetScope = 'resourceGroup'
param location string

//Virtual network for Application Gateway
param appGwVnetName string
param appGwVnetAddressPrefixes array
param appGwSubnetArray array
param hasPeering bool
param remoteVnetName string
param remoteRGVnetName string
param routingTableNameAppGw string
param routesAppGw array

//Virtual network for Web App
param webAppVnetName string
param webAppOutSubnetName string
param webAppVnetAddressPrefixes array
param webAppSubnetArray array
param routingTableNameWebApp string
param routesWebApp array

param allowVirtualNetworkAccess bool
param allowForwardedTraffic bool
param allowGatewayTransit bool
param useRemoteGateways bool

//Service Plan and Web App
param appServicePlanName string
param webAppName string
param containerImage string
param webAppSettingDiagName string

//Application Gateway parameters
param appGwName string
param appGwSubnetName string
param appGwWAFPolicyName string
param skuName string
param skuSize string
param backendAdressPools array
param backendHttpSettingsCollection array
param httpListeners array
param probes array
param publicIPAddressName string
param publicIpAddressProtect string
param appGwPrivateIpAddress string
param requestRoutingRules array
param zones array
param appGwSettingDiagName string

//Private endpoints parameters
param webAppCustomNetworkInterfaceName string
param webAppPrivateEndpointName string
param webAppPrivateEndpointSubnetName string

// Monitoring
param storageNetWatchName string
param logAnalyticsNetWatchName string
param mngResourceGroupName string
param networkWatcherName string

param settingDiaglogAnalyticsWSName string

module modLogAnalyticsDiag '../modules/loganalytics-diag-template.bicep' = {
  name: 'loganalyticsdiag-deployment'
  params: {
    location: location
    logAnalyticsWSName: settingDiaglogAnalyticsWSName
  }
}

module modWebAppVirtualNetwork '../modules/vnet-template.bicep' = {
  name: 'webappvirtualnetwork-deployment'
  params: {
    location: location
    vnetName: webAppVnetName
    vnetAddressPrefixes: webAppVnetAddressPrefixes
    subnetArray: webAppSubnetArray
    enableDdosProtection: false
    enableVmProtection: false
    hasPeering: hasPeering
    remoteVnetName: remoteVnetName
    remoteRGVnetName: remoteRGVnetName
    allowVirtualNetworkAccess: allowVirtualNetworkAccess
    allowForwardedTraffic: allowForwardedTraffic
    allowGatewayTransit: allowGatewayTransit
    useRemoteGateways: useRemoteGateways
    routingTableName: routingTableNameWebApp
    routes: routesWebApp
    logAnalyticsNetWatchName: logAnalyticsNetWatchName
    storageNetWatchName: storageNetWatchName
    mngResourceGroupName: mngResourceGroupName
    networkWatcherName: networkWatcherName
  }    
}

module modAppGWVirtualNetwork '../modules/vnet-template.bicep' = {
  name: 'appgwvirtualnetwork-deployment'
  params: {
    location: location
    vnetName: appGwVnetName
    vnetAddressPrefixes: appGwVnetAddressPrefixes
    subnetArray: appGwSubnetArray
    enableDdosProtection: false
    enableVmProtection: false
    hasPeering: hasPeering
    remoteVnetName: remoteVnetName
    remoteRGVnetName: remoteRGVnetName
    allowVirtualNetworkAccess: allowVirtualNetworkAccess
    allowForwardedTraffic: allowForwardedTraffic
    allowGatewayTransit: allowGatewayTransit
    useRemoteGateways: useRemoteGateways
    routingTableName: routingTableNameAppGw
    routes: routesAppGw
    logAnalyticsNetWatchName: logAnalyticsNetWatchName
    storageNetWatchName: storageNetWatchName
    mngResourceGroupName: mngResourceGroupName
    networkWatcherName: networkWatcherName
  }
  dependsOn: [
    modWebAppVirtualNetwork
  ]
}

module modSimpleDNSVirtualLinkWebApp '../modules/simplednsvirtuallink-template.bicep' = {
  name: 'simplednsvirtuallink-appgw-deployment'
  scope: resourceGroup(remoteRGVnetName)
  params: {
    privateDnsZoneName: 'privatelink.azurewebsites.net'
    vnetResourceGroupName: resourceGroup().name
    vnetName: appGwVnetName
    registrationEnabled: false
  }
  
  dependsOn: [
    modAppGWVirtualNetwork
  ]
}

module modWebApp '../modules/webapp-template.bicep' = {
  name: 'webapp-owaspjuiceshop-deployment'
  params: {
    location: location
    webAppName: webAppName
    appServicePlanName: appServicePlanName
    containerImage: containerImage
    vnetName: webAppVnetName
    subnetName: webAppOutSubnetName
    enableMonitoring: true
    settingDiagName: webAppSettingDiagName
    logAnalyticsWSid: modLogAnalyticsDiag.outputs.rscLogAnalyticsWSid
  }
}

module modWebAppPrivateEndpoint '../modules/privatendpoint-template.bicep' = {
  name: 'webapppvtendpoint-deployment'
  params:{
    location: location
    customNetworkInterfaceName: webAppCustomNetworkInterfaceName
    privateEndpointName: webAppPrivateEndpointName
    vnetName: webAppVnetName
    vnetHubResourceGroup: remoteRGVnetName
    vnetHubName: remoteVnetName
    privateEndpointSubnetName: webAppPrivateEndpointSubnetName
    privateZoneDNSName: 'privatelink.azurewebsites.net'
    privateLinkServiceId: modWebApp.outputs.rscWebAppId
    groupIds: ['sites']
    privateDNSZoneGroup: remoteRGVnetName
  }
  dependsOn: [
    modSimpleDNSVirtualLinkWebApp
    modWebAppVirtualNetwork
  ]
}

//App Gateway
module modAppGateway '../modules/appgw-waf-template.bicep' = {
  name: 'applgateway-deployment'
  params: {
    appGwName: appGwName
    appGwVnetName: appGwVnetName
    appGwSubnetName: appGwSubnetName
    appGwWAFPolicyName: appGwWAFPolicyName
    env: 'dev'
    skuName: skuName
    skuSize: skuSize
    backendAdressPools: backendAdressPools
    backendHttpSettingsCollection: backendHttpSettingsCollection
    httpListeners: httpListeners
    location: location
    probes: probes
    publicIPAddressName: publicIPAddressName
    publicIpAddressProtect: publicIpAddressProtect
    privateIPAddress: appGwPrivateIpAddress
    requestRoutingRules: requestRoutingRules
    zones: zones
    enableMonitoring: true
    appGwSettingDiagName: appGwSettingDiagName
    logAnalyticsWSid: modLogAnalyticsDiag.outputs.rscLogAnalyticsWSid
  }
  dependsOn: [
    modAppGWVirtualNetwork
  ]
}
