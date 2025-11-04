targetScope = 'resourceGroup'

param location string

//Virtual Network Parameters
param vnetName string
param vnetAddressPrefixes array
param subnetArray array
param publicIPAddressSettingDiagName string

//VPN Gateway
param VPNGWName string
param PIPName string
param aadAudience string
param tenantId string
param vpnClientAddressPool array
param sku string
param vpnGatewayGeneration string

//VPN Gateway Connection
param gatewaySettingDiagName string

//Azure Firewall
param fwMgmtPublicIpAddressName string
param fwName string
param fwNetworkRulesList array
param fwNatRulesList array
param fwAppRulesList array
param fwZones array
param fwPublicIpAddress array
param fwTier string
param fwSettingDiagName string


// Azure DNS private
param privateDNSZones array

//Monitoring
param logAnalyticsNetWatchName string
param mngResourceGroupName string
param storageNetWatchName string
param networkWatcherName string

param settingDiaglogAnalyticsWSName string

module modLogAnalyticsDiag '../modules/loganalytics-diag-template.bicep' = {
  name: 'loganalyticsdiag-deployment'
  scope: resourceGroup(mngResourceGroupName)
  params: {
    location: location
    logAnalyticsWSName: settingDiaglogAnalyticsWSName
  }
}

//Network Infrastructure
module modVirtualNetwork '../modules/vnet-hub-template.bicep' = {
  name: 'virtualNetwork-deployment'
  params: {
    location: location
    enableDdosProtection: false
    enableVmProtection: false
    vnetName: vnetName
    vnetAddressPrefixes: vnetAddressPrefixes
    subnetArray: subnetArray
    logAnalyticsNetWatchName: logAnalyticsNetWatchName
    storageNetWatchName: storageNetWatchName
    mngResourceGroupName: mngResourceGroupName
    networkWatcherName: networkWatcherName
  }
}

//VPN Gateway
module modVPNGateway '../modules/vpngateway-standardlz-template.bicep' = {
  name: 'vpngateway-deployment'
  params: {
    location: location
    VPNGWName: VPNGWName
    PIPName: PIPName
    vnetName: vnetName
    aadAudience: aadAudience
    tenantId: tenantId
    vpnClientAddressPool: vpnClientAddressPool
    sku: sku
    vpnGatewayGeneration: vpnGatewayGeneration
    enableMonitoring: true
    gatewaySettingDiagName: gatewaySettingDiagName
    publicIPAddressSettingDiagName: publicIPAddressSettingDiagName
    logAnalyticsWSid: modLogAnalyticsDiag.outputs.rscLogAnalyticsWSid
  }
  dependsOn: [
    modVirtualNetwork
  ]
}

//Azure Private DNS
module modPrivateDNSZone '../modules/azprivatedns-template.bicep' = {
  name: 'privatednszones-deployment'  
  params: {
    privateDNSZones: privateDNSZones
  }
}

//Azure Firewall
module modAzFirewall '../modules/azfirewall-template.bicep' = {
  name: 'azfirewall-deployment'
  params: {
    location: location
    azureFirewallName: fwName
    azureFirewallTier: fwTier
    networkRuleList: fwNetworkRulesList
    natRuleList: fwNatRulesList
    appRuleList: fwAppRulesList
    mgmtPublicIpAddressName: fwMgmtPublicIpAddressName
    publicIpAddressArray: fwPublicIpAddress
    vnetName: vnetName
    zones: fwZones
    enableMonitoring: true
    fwSettingDiagName: fwSettingDiagName
    publicIPAddressSettingDiagName: publicIPAddressSettingDiagName
    logAnalyticsWSid: modLogAnalyticsDiag.outputs.rscLogAnalyticsWSid
  }
  dependsOn: [
    modVirtualNetwork
  ]
}

output rscVnetID string = modVirtualNetwork.outputs.rscVNetId
output rscVnetName string = vnetName
