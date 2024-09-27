param name string
//param appInsightsConnectionString string
param logAnalyticsWorkspaceName string
param logAnalyticsWorkspaceSubscriptionId string
param logAnalyticsWorkspaceRG string
param location string
param tagsArray object

// resource appGatewayUserManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
//   name: '${name}-identity'
// }


// resource agicUserManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
//   name: '${name}-agic-identity'
//   location: location
//   tags: tagsArray
// }

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup(logAnalyticsWorkspaceSubscriptionId, logAnalyticsWorkspaceRG)
}

resource acaEnvironment 'Microsoft.App/managedEnvironments@2024-03-01'= {
  name: name
  location: location
  tags: tagsArray
  properties: {
    //daprAIConnectionString: appInsightsConnectionString
    appLogsConfiguration: {  
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
  }
}

// resource sslCertificates 'Microsoft.App/managedEnvironments/managedCertificates@2024-03-01' = {
//   parent: acaEnvironment
//   name: '${name}-ssl-certificates'
//   properties: {
//      domainControlValidation: 'TXT'
//      subjectName: ''
//   }
// }

resource acaDiagnotsicsLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${name}-aca-logs'
  scope: acaEnvironment
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
    workspaceId: logAnalyticsWorkspace.id
  }
}

output acaEnvironmentName string = acaEnvironment.name
output acaEnvironmentId string = acaEnvironment.id
output acaCustomDomainVerificationId string = acaEnvironment.properties.customDomainConfiguration.customDomainVerificationId
