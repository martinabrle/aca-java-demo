param name string
param vnetName string
param aksSubnetName string
//param appGatewayName string
param nodePoolRG string = '${((endsWith(resourceGroup().name, '_rg')) ? substring(resourceGroup().name, 0, length(resourceGroup().name) - 3) : resourceGroup().name)}_managed_resources_rg'
param aksAdminGroupObjectId string
param logAnalyticsWorkspaceId string
param location string
param tagsArray object

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: vnetName
}

resource aksSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = {
  parent: vnet
  name: aksSubnetName
}

// resource applicationGateway 'Microsoft.Network/applicationGateways@2023-05-01' existing = {
//   name: appGatewayName
// }

// resource appGatewayUserManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
//   name: '${name}-identity'
// }


resource agicUserManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${name}-agic-identity'
  location: location
  tags: tagsArray
}

resource aksService 'Microsoft.App/containerApps@2024-03-01' = {
  name: name
  location: location
  tags: tagsArray
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    activeRevisionMode: 'Auto'

    
  }
}
// TODO: fix
// var policySetBaseline = '/providers/Microsoft.Authorization/policySetDefinitions/a8640138-9b0a-4a28-b8cb-1666c838647d'
// var policySetRestrictive = '/providers/Microsoft.Authorization/policySetDefinitions/42b8ef37-b724-4e24-bbc8-7a7708edfe00'
//TODO: fix
// resource aks_policies 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
//   name: '${resourceName}-${azurePolicyInitiative}'
//   location: location
//   properties: {
//     policyDefinitionId: azurePolicyInitiative == 'Baseline' ? policySetBaseline : policySetRestrictive
//     parameters: {
//       excludedNamespaces: {
//         value: [
//             'kube-system'
//             'gatekeeper-system'
//             'azure-arc'
//             'cluster-baseline-setting'
//         ]
//       }
//       effect: {
//         value: azurepolicy
//       }
//     }
//     metadata: {
//       assignedBy: 'Aks Construction'
//     }
//     displayName: 'Kubernetes cluster pod security ${azurePolicyInitiative} standards for Linux-based workloads'
//     description: 'As per: https://github.com/Azure/azure-policy/blob/master/built-in-policies/policySetDefinitions/Kubernetes/'
//   }
// }

resource acaDiagnotsicsLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${name}-aca-logs'
  scope: aksService
  properties: {
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
      {
        categoryGroup: 'audit'
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

// resource aksNodePoolManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
//   name: '${aksService.name}-agentpool'
//   scope: resourceGroup(nodePoolRG)
// }

// module acaNodePoolManagedIdentity 'user-assigned-identity.bicep' = {
//   name: 'agentpool-identity'
//   scope: resourceGroup(nodePoolRG)
//   params: {
//     name: '${aksService.name}-agentpool'
//     rg: nodePoolRG
//   }
//   dependsOn: [
//     #disable-next-line no-unnecessary-dependson
//     aksService
//   ]
// }

// TODO: fix
// resource tmpOutboundIPAddressIDs 'Microsoft.Network/publicIPAddresses@2023-05-01' existing = [for publicIp in aksService.properties.networkProfile.loadBalancerProfile.outboundIPs.publicIPs : {
//   name: publicIp.id
// }]

// var tmp3 = [for (item, index) in tmpOutboundIPAddressIDs: ]

// output tmp2 string[] = map(aksService.properties.networkProfile.loadBalancerProfile.effectiveOutboundIPs, d => d.id)

// outboundIPAddressIDs

// var publicIpsStringArray = [for publicIp in publicIps : publicIp.properties.ipAddress]


// output aksNodePoolIdentityPrincipalId string = aksNodePoolManagedIdentity.outputs.principalId // aksNodePoolManagedIdentity.properties.principalId
// //Not using AGIC Addon - output aksIngressApplicationGatewayPrincipalId string = aksService.properties.addonProfiles.ingressApplicationGateway.identity.objectId
// @description('This output can be directly leveraged when creating a ManagedId Federated Identity')
// output aksOidcFedIdentityProperties object = {
//   issuer: aksService.properties.oidcIssuerProfile.issuerURL
//   audiences: ['api://AzureADTokenExchange']
//   subject: 'system:serviceaccount:ns:svcaccount'
// }

// // TODO: fix
// // output outboundIpAddresses string = concat(publicIpsStringArray)

// output agicIdentityPrincipalId string = agicUserManagedIdentity.properties.principalId
// output agicIdentityClientId string = agicUserManagedIdentity.properties.clientId
// output agicIdentityResourceId string = agicUserManagedIdentity.id
// output agicIdentityName string = agicUserManagedIdentity.name
