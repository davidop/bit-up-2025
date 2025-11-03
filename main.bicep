targetScope = 'subscription'

param location string = 'northeurope'
//Monitoring
param connectStorageNetWatchName string
param juiceShopStgNetWatchName  string
param connectSettingDiaglogAnalyticsWSName string
param juiceShopSettingDiaglogAnalyticsWSName string
param connectLogAnalyticsNetWatchName string
param juiceShopLogAnalyticsNetWatchName string
param networkWatcherName string

//Connectivity
param aadAudience string
param fwMgmtPublicIpAddressName string
param fwName string
param fwNatRulesList array
param fwNetworkRulesList array
param fwPublicIpAddress array
param fwSettingDiagName string
param fwTier string
param fwZones array
param gatewaySettingDiagName string
param PIPName string
param privateDNSZones array
param publicIPAddressSettingDiagName string
param sku string
param subnetArray array
param tenantId string
param vnetAddressPrefixes array
param vnetName string
param vpnClientAddressPool array
param vpnGatewayGeneration string
param VPNGWName string

//Owasp Juice Shop Workload
param webAppVnetName string
param webAppVnetAddressPrefixes array
param webAppSubnetArray array
param routingTableNameWebApp string
param routesWebApp array
param webAppOutSubnetName string
param routingTableNameAppGw string
param routesAppGw array
param appServicePlanName string
param containerImage string
param webAppName string
param webAppSettingDiagName string
param webAppCustomNetworkInterfaceName string
param webAppPrivateEndpointName string
param webAppPrivateEndpointSubnetName string
param appGwSubnetArray array
param appGwVnetAddressPrefixes array
param appGwVnetName string
param appGwPrivateIpAddress string
param appGwName string
param appGwSettingDiagName string
param appGwSubnetName string
param appGwWAFPolicyName string
param backendAddressPools array
param backendHttpSettingsCollection array
param httpListeners array
param probes array
param publicIPAddressName string
param publicIpAddressProtect string
param requestRoutingRules array
param skuName string
param skuSize string
param zones array



// Resource groups that act like logical 'subscriptions'
resource rgConnectivity 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-connectivity-bitup2025'
  location: location
}

resource rgManagement 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-management-bitup2025'
  location: location
}

resource rgOWASPJuiceShop 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-owasp-juiceshop-bitup2025'
  location: location
}

module modManagementMain 'submains/management-main.bicep' = {
  name: 'management-deployment'
  scope: resourceGroup(rgManagement.name)
  params: {
    location: location
    networkWatcherName: networkWatcherName
    connectStorageNetWatchName: connectStorageNetWatchName
    juiceShopStgNetWatchName: juiceShopStgNetWatchName
    connectSettingDiaglogAnalyticsWSName: connectSettingDiaglogAnalyticsWSName
    juiceShopSettingDiaglogAnalyticsWSName: juiceShopSettingDiaglogAnalyticsWSName
  }
}

// Sub-main modules: each one is deployed into its Resource Group and orchestrará módulos locales
module modConnectivityMain 'submains/connectivity-main.bicep' = {
  name: 'connectivity-deployment'
  scope: resourceGroup(rgConnectivity.name)
  params: {
    location: location
    aadAudience: aadAudience
    fwAppRulesList: []
    fwMgmtPublicIpAddressName: fwMgmtPublicIpAddressName
    fwName: fwName
    fwNatRulesList: fwNatRulesList
    fwNetworkRulesList: fwNetworkRulesList
    fwPublicIpAddress: fwPublicIpAddress
    fwSettingDiagName: fwSettingDiagName
    fwTier: fwTier
    fwZones: fwZones
    gatewaySettingDiagName: gatewaySettingDiagName
    logAnalyticsNetWatchName: connectLogAnalyticsNetWatchName
    PIPName: PIPName
    privateDNSZones: privateDNSZones
    publicIPAddressSettingDiagName: publicIPAddressSettingDiagName
    settingDiaglogAnalyticsWSName: connectSettingDiaglogAnalyticsWSName
    sku: sku
    storageNetWatchName: connectStorageNetWatchName
    subnetArray: subnetArray
    tenantId: tenantId
    vnetAddressPrefixes: vnetAddressPrefixes
    vnetName: vnetName
    vpnClientAddressPool: vpnClientAddressPool
    vpnGatewayGeneration: vpnGatewayGeneration
    VPNGWName: VPNGWName
    mngResourceGroupName: rgManagement.name
    networkWatcherName: networkWatcherName
  }
  dependsOn: [
    modManagementMain
  ]
}

module modOWASPJuiceShopMain 'submains/owaspjuiceshop-main.bicep' = {
  name: 'owaspjuiceshop-deployment'
  scope: resourceGroup(rgOWASPJuiceShop.name)
  params: {
    allowForwardedTraffic: true
    allowGatewayTransit: false
    allowVirtualNetworkAccess: true
    appGwSubnetArray: appGwSubnetArray
    appGwVnetAddressPrefixes: appGwVnetAddressPrefixes
    appGwVnetName: appGwVnetName
    hasPeering: true
    location: location
    logAnalyticsNetWatchName: juiceShopLogAnalyticsNetWatchName
    mngResourceGroupName: rgManagement.name
    remoteRGVnetName: rgConnectivity.name
    remoteVnetName: modConnectivityMain.outputs.rscVnetName
    routingTableNameAppGw: routingTableNameAppGw
    routesAppGw: routesAppGw
    storageNetWatchName: juiceShopStgNetWatchName
    useRemoteGateways: true
    networkWatcherName: networkWatcherName
    appServicePlanName: appServicePlanName
    containerImage: containerImage
    webAppName: webAppName
    webAppOutSubnetName: webAppOutSubnetName
    webAppSubnetArray: webAppSubnetArray
    webAppVnetAddressPrefixes: webAppVnetAddressPrefixes
    webAppVnetName: webAppVnetName
    webAppSettingDiagName: webAppSettingDiagName
    routesWebApp: routesWebApp
    routingTableNameWebApp: routingTableNameWebApp
    webAppCustomNetworkInterfaceName: webAppCustomNetworkInterfaceName
    webAppPrivateEndpointName: webAppPrivateEndpointName
    webAppPrivateEndpointSubnetName: webAppPrivateEndpointSubnetName
    appGwName: appGwName
    appGwPrivateIpAddress: appGwPrivateIpAddress
    appGwSettingDiagName: appGwSettingDiagName
    appGwSubnetName: appGwSubnetName
    appGwWAFPolicyName: appGwWAFPolicyName
    backendAdressPools: backendAddressPools
    backendHttpSettingsCollection: backendHttpSettingsCollection
    httpListeners: httpListeners
    probes: probes
    publicIPAddressName: publicIPAddressName
    publicIpAddressProtect: publicIpAddressProtect
    requestRoutingRules: requestRoutingRules
    skuName: skuName
    skuSize: skuSize
    zones: zones
    settingDiaglogAnalyticsWSName: juiceShopSettingDiaglogAnalyticsWSName
   }
}


// Exponer outputs de interés
//output managementStorage string = managementMain.outputs.storageAccountName
