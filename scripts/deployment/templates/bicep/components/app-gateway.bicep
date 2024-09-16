param name string
param vnetName string
param appGatewaySubnetName string
param sslCertKeyVaultToDoSecretUri string = ''
param sslCertKeyVaultPetClinicSecretUri string = ''
param location string
param tagsArray object

param logAnalyticsWorkspaceId string

resource appGatewayUserManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${name}-identity'
  location: location
  tags: tagsArray
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: vnetName
}

resource appGatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = {
  name: appGatewaySubnetName
  parent: vnet
}

resource appGatewayPublicIPAddress 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: '${name}-ip'
  location: location
  tags: tagsArray
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource appGateway 'Microsoft.Network/applicationGateways@2023-05-01' = {
  // good drawing here: https://dev.to/kaiwalter/azure-application-gateway-for-dummies-dj3
  name: name
   identity: {
     type: 'UserAssigned'
     userAssignedIdentities: {
      '${appGatewayUserManagedIdentity.id}': {}
    }
  }
  location: location
  tags: tagsArray
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
      capacity: 1
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: appGatewaySubnet.id
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIp'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: appGatewayPublicIPAddress.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_80'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'defaultaddresspool'
        //properties: {}
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'myHTTPSetting'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: false
          requestTimeout: 20
        }
      }
    ]
    sslCertificates: concat(
      [
        !empty(sslCertKeyVaultToDoSecretUri) ? {
          name: 'appGatewaySslCertToDo'
          properties: {
            keyVaultSecretId: sslCertKeyVaultToDoSecretUri
          }
        } : {}],
      [
        !empty(sslCertKeyVaultPetClinicSecretUri) ? {
          name: 'appGatewaySslCertPetClinic'
          properties: {
            keyVaultSecretId: sslCertKeyVaultPetClinicSecretUri
          }
        } : { }
      ])

    httpListeners: [
      {
        name: 'myListener'
        properties: {
          firewallPolicy: {
            id: appGatewayPolicy.id
          }
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', name, 'appGwPublicFrontendIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', name, 'port_80')
          }
          protocol: 'Http'
          requireServerNameIndication: false
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'myRoutingRule'
        properties: {
          ruleType: 'Basic'
          priority: 10
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', name, 'myListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', name, 'defaultaddresspool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', name, 'myHTTPSetting')
          }
        }
      }
    ]
    enableHttp2: false
    firewallPolicy: {
      id: appGatewayPolicy.id
    }
  }
}

resource appGatewayPolicy 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2023-05-01' = {
  name: '${name}-policy'
  location: location
  tags: tagsArray
  properties: {
    customRules: [
      {
        name: 'CustRule01'
        priority: 100
        ruleType: 'MatchRule'
        action: 'Block'
        matchConditions: [
          {
            matchVariables: [
              {
                variableName: 'RemoteAddr'
              }
            ]
            operator: 'IPMatch'
            negationConditon: true
            matchValues: [
              '10.10.10.0/24'
            ]
          }
        ]
      }
    ]
    policySettings: {
      requestBodyCheck: true
      maxRequestBodySizeInKb: 128
      fileUploadLimitInMb: 100
      state: 'Enabled'
      mode: 'Prevention'
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'OWASP'
          ruleSetVersion: '3.1'
        }
      ]
    }
  }
}

resource appGatewayDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: appGateway
  name: '${name}-logs'
  properties: {
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
    workspaceId: logAnalyticsWorkspaceId
  }
}

output appGatewayId string = appGateway.id
output appGatewayName string = appGateway.name
output appGatewayIdentityPrincipalId string = appGatewayUserManagedIdentity.properties.principalId
output appGatewayIdentityClientId string = appGatewayUserManagedIdentity.properties.clientId
output appGatewayIdentityResourceId string = appGatewayUserManagedIdentity.id
output appGatewayIdentityName string = appGatewayUserManagedIdentity.name
output appGatewayPolicyId string = appGatewayPolicy.id
output appGatewayPolicyName string = appGatewayPolicy.name
