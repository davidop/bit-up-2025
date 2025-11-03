param location string

param VPNGWName string
param PIPName string
param vnetName string
param aadAudience string
param tenantId string
param vpnClientAddressPool array
param sku string
param vpnGatewayGeneration string

//Monitoring
param enableMonitoring bool = false
param gatewaySettingDiagName string = ''
param publicIPAddressSettingDiagName string = ''
param logAnalyticsWSid string = ''


resource rscGWVnet  'Microsoft.Network/virtualNetworks@2022-05-01' existing = {
  name: vnetName
}
resource rscGWSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-05-01' existing = {
  parent: rscGWVnet
  name: 'GatewaySubnet'
}

resource rscPublicIPAddress 'Microsoft.Network/publicIPAddresses@2022-11-01' = {
  location: location
  name: PIPName
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource rscVPNGateway 'Microsoft.Network/virtualNetworkGateways@2023-09-01' = {
  location: location
  name: VPNGWName
  properties: {
    gatewayType: 'Vpn'
    ipConfigurations: [
      {
        name: 'vnetGatewayConfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: rscGWSubnet.id
          }
          publicIPAddress: {
            id: rscPublicIPAddress.id
          }          
        }
      }
    ]
    sku: {
      name: sku
      tier: sku
    }
    enableBgp: false
    activeActive: false
    vpnType: 'RouteBased'
    vpnGatewayGeneration: vpnGatewayGeneration
    vpnClientConfiguration: {
      aadAudience: aadAudience
      aadIssuer: 'https://sts.windows.net/${tenantId}/'
      aadTenant: 'https://login.microsoftonline.com/${tenantId}/'
      vpnAuthenticationTypes: [
        'AAD'
      ]
      vpnClientAddressPool: {
        addressPrefixes: vpnClientAddressPool
      }
      vpnClientProtocols: [
        'OpenVPN'
      ]
    }
  }
}

resource rscGatewayDiagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if(enableMonitoring) {
  name: gatewaySettingDiagName
  scope: rscVPNGateway
  properties: {
    workspaceId: logAnalyticsWSid
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
  }
}

resource rscPiPDiagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if(enableMonitoring) {
  name: publicIPAddressSettingDiagName
  scope: rscPublicIPAddress
  properties: {
    workspaceId: logAnalyticsWSid
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
  }
}

output rscVPNGatewayId string = rscVPNGateway.id 
