using './main.bicep'  

param location                                = 'northeurope'
param vnetName                                = 'vnet-bitup2025-hub-northeu-01'
param vnetAddressPrefixes                     = ['10.20.0.0/23']
param subnetArray                             = [
                                                  {
                                                    subnetName: 'AzureFirewallSubnet'
                                                    subnetAddressPrefix: '10.20.0.0/26'
                                                    NSGName: ''
                                                    routeTableName: ''
                                                    routes: []
                                                    delegations: []
                                                  }
                                                  {
                                                    subnetName: 'AzureFirewallManagementSubnet'
                                                    subnetAddressPrefix: '10.20.0.64/26'
                                                    NSGName: ''
                                                    routeTableName: ''
                                                    routes: []
                                                    delegations: []
                                                  }
                                                  {
                                                    subnetName: 'GatewaySubnet'
                                                    subnetAddressPrefix: '10.20.1.192/26'
                                                    NSGName: ''
                                                    routeTableName: 'hub-bitup2025-gateway-subnet-northeu'
                                                    routes: []
                                                    delegations: []
                                                  }
                                                ]
//VPN Gateway                                    
param VPNGWName                               = 'vpngw-bitup2025-hq-northeu-01'
param PIPName                                 = 'pip-vpngw-bitup2025-hq-northeu-01'
param aadAudience                             = '41b23e61-6c1e-4545-b367-cd054e0ed4b4'
param tenantId                                = 'cd3e0b1c-231c-4e46-848a-d46a038c05ab'
param vpnClientAddressPool                    = ['10.20.6.0/23']
param sku                                     = 'VpnGw1'
param vpnGatewayGeneration                    = 'Generation1'

//DNS Resources 
param privateDNSZones                         = []
param publicIPAddressSettingDiagName          = 'diagset-bitup2025-pip-connectivity'

//Firewall  
param fwMgmtPublicIpAddressName               = 'pip-bitup2025-afw-mgmt-hub-northeu-01'
param fwName                                  = 'afw-bitup2025-hub-northeu-01'
param fwNetworkRulesList                      = [
                                                  {
                                                    name: 'Azure-to-Azure'
                                                    priority: 1000
                                                    action: 'Allow'
                                                    rules: [
                                                      {
                                                        name: 'Azure-to-Azure'
                                                        protocols: ['Any']
                                                        sourceAddresses: ['10.20.0.0/16']
                                                        destinationAddresses: ['10.20.0.0/16']
                                                        sourceIpGroups: []
                                                        destinationIpGroups: []
                                                        destinationFqdns: []
                                                        destinationPorts: ['*']
                                                      }
                                                    ]
                                                  }
                                                ]
param fwNatRulesList                          = []
param fwZones                                 = ['1']
param fwPublicIpAddress                       = [
                                                  {
                                                    name: 'pip-bitup2025-afw-hub-northeu-01'
                                                    allocationMethod: 'Static'
                                                    protectionMode: 'Disabled'
                                                  }
                                                ]
param fwTier                                  = 'basic'
param fwSettingDiagName                       = 'diagset-bitup2025firewall-connectivity'

//Monitoring  
param connectSettingDiaglogAnalyticsWSName    = 'la-bitup2025-monitor-connectivity'
param connectLogAnalyticsNetWatchName         = 'la-bitup2025-networkwatcher-connectivity'
param connectStorageNetWatchName              = 'stbunetwatconnne01'
param networkWatcherName                      = 'nw-bitup2025-northeu-01'
param gatewaySettingDiagName                  = 'diagset-bitup2025-vpngateway-connectivity'

//Owasp Juice Shop Workload 
param webAppVnetName                          = 'vnet-bitup2025-webapp-juice-shop-ne'
param webAppOutSubnetName                     = 'snet-bitup2025-webapp-out-juice-shop-ne'  
param webAppVnetAddressPrefixes               = ['10.20.18.0/24']
param webAppSubnetArray                       = [
                                                  {
                                                    subnetName: 'snet-bitup2025-webapp-in-juice-shop-ne'
                                                    subnetAddressPrefix: '10.20.18.0/26'
                                                    NSGName: 'nsg-bitup2025-webapp-in-juice-shop-ne'
                                                    delegations: []
                                                  }
                                                  {
                                                    subnetName: 'snet-bitup2025-webapp-out-juice-shop-ne'
                                                    subnetAddressPrefix: '10.20.18.64/26'
                                                    NSGName: 'nsg-bitup2025-webapp-out-juice-shop-ne'
                                                    delegations: [{
                                                      name: 'delegationAppService'
                                                      properties: {
                                                        serviceName: 'Microsoft.Web/serverFarms'
                                                      }
                                                    }]

                                                  }
                                                ]
param routesWebApp                            = [
                                                  {
                                                    name: 'rt-vnet-bitup2025-juice-shop-ne'
                                                    properties : {
                                                      addressPrefix: '10.20.0.0/24'
                                                      nextHopType: 'VirtualAppliance'
                                                      nextHopIpAddress: '10.20.0.4'
                                                    }
                                                  }
                                                ]

param routingTableNameWebApp                  = 'rt-bitup2025-spoke-webapp'
param appServicePlanName                      = 'asp-juice-shop-bitup2025-ne'  
param containerImage                          = 'bkimminich/juice-shop:latest'
param webAppName                              = 'webapp-juice-shop-bitup2025-ne'
param webAppSettingDiagName                   = 'diagset-bitup2025-webapp-ne'
param webAppCustomNetworkInterfaceName        = 'nic-webapp-juice-shop-bitup2025-ne'
param webAppPrivateEndpointName               = 'pep-webapp-juice-shop-bitup2025-ne'
param webAppPrivateEndpointSubnetName         = 'snet-bitup2025-webapp-in-juice-shop-ne'

param routesAppGw                             = [
                                                  {
                                                    name: 'rt-vnet-bitup2025-webapp-juice-shop-ne'
                                                    properties : {
                                                      addressPrefix: '10.20.18.0/24'
                                                      nextHopType: 'VirtualAppliance'
                                                      nextHopIpAddress: '10.20.0.4'
                                                    }
                                                  }
                                                ]
param appGwSubnetArray                        = [
                                                  {
                                                    subnetName: 'snet-bitup2025-appgw-ne'
                                                    subnetAddressPrefix: '10.20.19.0/24'
                                                    NSGName: 'nsg-bitup2025-appgw-ne'
                                                    properties: {
                                                      securityRules: [
                                                        {
                                                          name: 'AllowAppGatewayCustomPortsRange1'
                                                          properties: {
                                                            protocol: '*'
                                                            sourcePortRange: '*'
                                                            destinationPortRange: '65200-65535'
                                                            sourceAddressPrefix: '*'
                                                            destinationAddressPrefix: '*'
                                                            access: 'Allow'
                                                            direction: 'Inbound'
                                                            priority: 100
                                                            sourcePortRanges: []
                                                            destinationPortRanges: []
                                                            sourceAddressPrefixes: []
                                                            destinationAddressPrefixes: []
                                                          }
                                                        }
                                                        {
                                                          name: 'AllowAppGatewayCustomPorts80'
                                                          properties: {
                                                            protocol: 'TCP'
                                                            sourcePortRange: '*'
                                                            destinationPortRange: '80'
                                                            sourceAddressPrefix: '*'
                                                            destinationAddressPrefix: '*'
                                                            access: 'Allow'
                                                            direction: 'Inbound'
                                                            priority: 110
                                                            sourcePortRanges: []
                                                            destinationPortRanges: []
                                                            sourceAddressPrefixes: []
                                                            destinationAddressPrefixes: []
                                                          }
                                                        }
                                                        {
                                                          name: 'AllowAppGatewayCustomPorts443'
                                                          properties: {
                                                            protocol: 'TCP'
                                                            sourcePortRange: '*'
                                                            destinationPortRange: '443'
                                                            sourceAddressPrefix: '*'
                                                            destinationAddressPrefix: '*'
                                                            access: 'Allow'
                                                            direction: 'Inbound'
                                                            priority: 120
                                                            sourcePortRanges: []
                                                            destinationPortRanges: []
                                                            sourceAddressPrefixes: []
                                                            destinationAddressPrefixes: []
                                                          }
                                                        }
                                                      ]
                                                    }
                                                    delegations: []
                                                  }
                                                ]
param appGwVnetAddressPrefixes                = ['10.20.19.0/24']
param appGwVnetName                           = 'vnet-bitup2025-appgw-ne'
param routingTableNameAppGw                   = 'rt-bitup2025-spoke-appgw'
param appGwName                               = 'appgw-bitup2025-ne'
param appGwSettingDiagName                    = 'diagset-bitup2025-appgw-ne'
param appGwSubnetName                         = 'snet-bitup2025-appgw-ne'
param appGwPrivateIpAddress                   = '10.20.19.100'
param appGwWAFPolicyName                      = 'wafpolicy-bitup2025-appgw-ne'
param backendAddressPools                     = [
                                                  {
                                                      name: 'bckpool-bitup2025-juice-shop-webapp'
                                                      properties: {
                                                          backendAddresses: [
                                                            {
                                                             fqdn: 'webapp-juice-shop-bitup2025-ne.azurewebsites.net'
                                                            }
                                                          ]
                                                      }
                                                  }
                                                ]
                                              
param backendHttpSettingsCollection           = [
                                                  {
                                                    name: 'bkndhttpset-bitup2025-juice-shop'
                                                    port: 443
                                                    protocol: 'Https'
                                                    cookieBasedAffinity: 'Disabled'
                                                    requestTimeout: 20
                                                    hostName: 'webapp-juice-shop-bitup2025-ne.azurewebsites.net'
                                                    probeName:'appgw-httpsprobe-bitup2025-juice-shop'
                                                  }
                                                ]
param httpListeners                           = [
                                                  {
                                                    name: 'httpsltng-bitup2025-juice-shop'
                                                    protocol: 'Https'
                                                    hostName: 'webapp-juice-shop.bitup.com'
                                                    requireServerNameIndication: true
                                                    frontendIPAddressType: 'Public'
                                                  }
                                                ]
                                              
param probes                                  = [
                                                  {
                                                    name: 'appgw-httpsprobe-bitup2025-juice-shop'
                                                    properties: {
                                                        interval: 30
                                                        minServers: 0
                                                        path: '/'
                                                        protocol: 'Https'
                                                        timeout: 30
                                                        unhealthyThreshold: 3
                                                        pickHostNameFromBackendHttpSettings: false
                                                        host: 'webapp-juice-shop-bitup2025-ne.azurewebsites.net'
                                                    }
                                                  }
                                                ]
param publicIPAddressName                     = 'pip-appgw-frontend-bitup2025-ne-01'
param publicIpAddressProtect                  = 'Enabled'
param requestRoutingRules                     = [
                                                  {
                                                    Name: 'routingrule-bitup2025-juice-shop'
                                                    RuleType: 'Basic'
                                                    priority: 100
                                                    httplistenername: 'httpsltng-bitup2025-juice-shop'
                                                    backendaddresspoolname: 'bckpool-bitup2025-juice-shop-webapp'
                                                    backendhttpsettingsname: 'bkndhttpset-bitup2025-juice-shop'
                                                  
                                                  }
                                                ]
param skuName                                 = 'WAF_v2'
param skuSize                                 = 'WAF_v2'
param zones                                   = ['1','2','3']
param juiceShopSettingDiaglogAnalyticsWSName  = 'la-bitup2025-appgw-juice-shop-ne'
param juiceShopLogAnalyticsNetWatchName       = 'la-bitup2025-networkwatcher-juiceshop'
param juiceShopStgNetWatchName                = 'stbunetwatjsne01'
