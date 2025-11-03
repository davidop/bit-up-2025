param location string
param env string
param publicIPAddressName string
param publicIpAddressProtect string
param privateIPAddress string
param appGwWAFPolicyName string
param appGwVnetName string
param appGwSubnetName string
param appGwName string
param fwMngIdentityName string = ''
param zones array
param skuName string
param skuSize string
param capacity int = 2
param backendAdressPools array
param backendHttpSettingsCollection array
param httpListeners array
param requestRoutingRules array
param probes array
@secure()
param keyVaultSecretId string = ''
param kvSSLCertificateName string = ''

//monitoring
param enableMonitoring bool
param appGwSettingDiagName string
param logAnalyticsWSid string

var publicFrontendIPConfName = 'appGwPublicFrontendIpIPv4-${env}'
var privateFrontendIPConfName = 'appGwPrivateFrontendIpIPv4-${env}'

module modAppGwPublicIp 'publicipaddress-template.bicep' = {
  name: 'appgwpublicip-deployment'
  params: {
    location: location
    publicIPAddressName: publicIPAddressName
    publicIpAddressProtect: publicIpAddressProtect
    zones: zones
    enableMonitoring: true
    logAnalyticsWSid: logAnalyticsWSid
    publicIPSettingDiagName: 'diagset-publicip-opcenter'
  }
}

resource rscWAFPolicies 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2023-09-01' = {
  name: appGwWAFPolicyName
  location: location
  properties: {
    policySettings: {
      mode: 'Detection'
      state: 'Enabled'
      fileUploadLimitInMb: 100
      requestBodyCheck: true
      maxRequestBodySizeInKb: 128
    }
    managedRules: {
      exclusions: []
      managedRuleSets:  [
        {
          ruleSetType: 'OWASP'
          ruleSetVersion: '3.2'
          ruleGroupOverrides: null
        }
      ]
    }
    customRules: []
  }
}

resource rscAppGwVnet 'Microsoft.Network/virtualNetworks@2022-11-01' existing = {
  name: appGwVnetName
}
resource rscAppSubnetName 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  parent: rscAppGwVnet
  name: appGwSubnetName
}

resource rscFwMngIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = if (!empty(fwMngIdentityName)) {
  name: fwMngIdentityName
}

resource rscAppGateway 'Microsoft.Network/applicationGateways@2023-09-01' = {
  name: appGwName
  location: location
  zones: zones
  properties: {
    sku: {
      name: skuName
      tier: skuSize
      capacity: capacity
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: rscAppSubnetName.id
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: publicFrontendIPConfName
        properties: {
          publicIPAddress: {
            id: modAppGwPublicIp.outputs.rscAppGwPublicIpId
          }
        }
      }
      {
        name: privateFrontendIPConfName
        properties: {
          privateIPAddress: privateIPAddress
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: rscAppSubnetName.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_443'
        properties:{
          port: 443
        }
      }
      {
        name: 'port_80'
        properties:{
          port: 80
        } 
      }
    ]
    backendAddressPools: backendAdressPools
    backendHttpSettingsCollection: [for backendHttpSettingsItem in backendHttpSettingsCollection: {
      name: backendHttpSettingsItem.name
      properties: {
        port: backendHttpSettingsItem.port
        protocol: backendHttpSettingsItem.protocol
        cookieBasedAffinity: backendHttpSettingsItem.cookieBasedAffinity
        requestTimeout: backendHttpSettingsItem.requestTimeout
        hostName: backendHttpSettingsItem.hostName
        probe: empty(backendHttpSettingsItem.probeName) ? null : {
          id: resourceId('Microsoft.Network/applicationGateways/probes', appGwName, backendHttpSettingsItem.probeName)
        }
      }
    }]
    httpListeners: [
      for httpListener in httpListeners: {
        name: httpListener.name
        properties: {
          frontendIPConfiguration: (httpListener.frontendIPAddressType == 'Public') ? {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appGwName, publicFrontendIPConfName)
          } : {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appGwName, privateFrontendIPConfName)
          }
          frontendPort: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/frontendPorts',
              appGwName,
              (!empty(keyVaultSecretId) && httpListener.protocol == 'Https') ? 'port_443' : 'port_80'
            )
          }
          sslCertificate: (!empty(keyVaultSecretId) && httpListener.protocol == 'Https') ? {
            id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', appGwName, kvSSLCertificateName)
          } : null
          hostName: httpListener.hostName
          protocol: (!empty(keyVaultSecretId) && httpListener.protocol == 'Https') ? 'Https' : 'Http'
        }
      }
    ]
    requestRoutingRules: [for requestRoutingRule in requestRoutingRules: {
      name: requestRoutingRule.name
      properties: {
        httpListener: {
          id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appGwName, requestRoutingRule.httplistenername)
        }
        priority: requestRoutingRule.priority
        backendAddressPool: {
          id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appGwName, requestRoutingRule.backendaddresspoolname)
        }
        backendHttpSettings: {
          id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', appGwName, requestRoutingRule.backendhttpsettingsname)
        }
      }
    }]
    enableHttp2: true
    sslCertificates: empty(keyVaultSecretId) ? [] : [
      {
        name: kvSSLCertificateName
        properties: {
          keyVaultSecretId: keyVaultSecretId
        }
      }
    ]
    probes: probes
    firewallPolicy: {
      id: rscWAFPolicies.id
    }
  }
  identity: empty(fwMngIdentityName) ? null : {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${rscFwMngIdentity.id}': {}
    }
  }
  dependsOn: empty(fwMngIdentityName) ? [] : [
    rscFwMngIdentity
  ]
}

resource appGwDiagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if(enableMonitoring) {
  name: appGwSettingDiagName
  scope: rscAppGateway
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

output rscAppGatewayId string = rscAppGateway.id
