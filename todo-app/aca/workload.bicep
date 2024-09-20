param acaName string

param todoAppUserManagedIdentityName string = '${acaName}-todo-app-identity'

// param containerRegistryName string = replace(replace(acaName, '_', ''), '-', '')
// param containerRegistrySubscriptionId string = subscription().id
// param containerRegistryRG string = resourceGroup().name

// var containerRegistrySubscriptionIdVar = (containerRegistrySubscriptionId == '')
//   ? subscription().id
//   : containerRegistrySubscriptionId
// var containerRegistryRGVar = (containerRegistryRG == '') ? resourceGroup().name : containerRegistryRG

param location string

resource todoAppUserManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: todoAppUserManagedIdentityName
}

resource kvSecretTodoAppSpringDSURI 'Microsoft.KeyVault/vaults/secrets@2024-04-01-preview' existing = {
  parent: keyVault
  name: 'TODO-SPRING-DATASOURCE-URL'
}

resource kvSecretTodoAppDbUserName 'Microsoft.KeyVault/vaults/secrets@2024-04-01-preview' existing = {
  parent: keyVault
  name: 'TODO-SPRING-DATASOURCE-USERNAME'
}

resource kvSecretTodoAppInsightsConnectionString 'Microsoft.KeyVault/vaults/secrets@2024-04-01-preview' existing = {
  parent: keyVault
  name: 'TODO-APP-INSIGHTS-CONNECTION-STRING'
}

resource kvSecretTodoAppInsightsInstrumentationKey 'Microsoft.KeyVault/vaults/secrets@2024-04-01-preview' existing = {
  parent: keyVault
  name: 'TODO-APP-INSIGHTS-INSTRUMENTATION-KEY'
}

resource keyVault 'Microsoft.KeyVault/vaults@2024-04-01-preview' existing = {
  name: '${acaName}-kv'
}

// resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' existing = {
//   name: containerRegistryName
//   scope: resourceGroup(containerRegistrySubscriptionIdVar, containerRegistryRGVar)
// }

resource acaEnvironment 'Microsoft.App/managedEnvironments@2024-03-01' existing = {
  name: acaName
}

resource acaApp 'Microsoft.App/containerApps@2024-03-01' = {
   name: 'fe'
   identity: {
      type: 'UserAssigned'
       userAssignedIdentities: {
         '${todoAppUserManagedIdentity.id}': {}
       }
   }
   properties: {
      environmentId: acaEnvironment.id 
      configuration: {
          activeRevisionsMode: 'Single'
      }
      template: {
          containers: [
            {
              image: 'mcr.microsoft.com/azure-samples/azure-vote-front:v1'
              name: 'frontend'
              env: [
                {
                  name: replace(kvSecretTodoAppSpringDSURI.name,'-','_')
                  secretRef: kvSecretTodoAppSpringDSURI.id
                }
                {
                  name: replace(kvSecretTodoAppDbUserName.name,'-','_')
                  secretRef: kvSecretTodoAppDbUserName.name
                }
                {
                  name: replace(kvSecretTodoAppInsightsConnectionString.name,'-','_')
                  secretRef: kvSecretTodoAppInsightsConnectionString.name
                }
                {
                  name: replace(kvSecretTodoAppInsightsInstrumentationKey.name,'-','_')
                  secretRef: kvSecretTodoAppInsightsInstrumentationKey.name
                }
              ]
              resources: {
                 cpu: 1
                 memory: '0.25Gi'
              }
            }
          ]
      }
    }
    location: location
}
