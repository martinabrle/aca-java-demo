param acaName string
param acaTags string

param pgsqlName string = '${replace(acaName,'_','-')}-pgsql'
param pgsqlTodoAppDbName string
param todoAppDbUserName string // = 'todo_app' - moved to GH secrets

param todoAppUserManagedIdentityName string = '${acaName}-todo-app-identity'

param containerRegistryName string = replace(replace(acaName,'_', ''),'-','')
param containerRegistrySubscriptionId string = subscription().id
param containerRegistryRG string = resourceGroup().name

var containerRegistrySubscriptionIdVar = (containerRegistrySubscriptionId == '') ? subscription().id : containerRegistrySubscriptionId
var containerRegistryRGVar = (containerRegistryRG == '') ? resourceGroup().name : containerRegistryRG

var acaTagsArray = json(acaTags)

param location string

resource todoAppUserManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: todoAppUserManagedIdentityName
  location: location
  tags: acaTagsArray
}

resource todoAppInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: '${acaName}-todo-ai'
}

resource keyVault 'Microsoft.KeyVault/vaults@2024-04-01-preview' existing = {
  name: '${acaName}-kv'
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' existing = {
  name: containerRegistryName
  scope: resourceGroup(containerRegistrySubscriptionIdVar, containerRegistryRGVar)
}

module kvSecretTodoAppSpringDSURI 'components/kv-secret.bicep' = {
  name: 'kv-secret-todo-app-ds-uri'
  params: {
    keyVaultName: keyVault.name
    secretName: 'TODO-SPRING-DATASOURCE-URL'
    secretValue: 'jdbc:postgresql://${pgsqlName}.postgres.database.azure.com:5432/${pgsqlTodoAppDbName}'
  }
}

module kvSecretTodoAppDbUserName 'components/kv-secret.bicep' = {
  name: 'kv-secret-todo-app-ds-username'
  params: {
    keyVaultName: keyVault.name
    secretName: 'TODO-SPRING-DATASOURCE-USERNAME'
    secretValue: todoAppDbUserName
  }
}

module kvSecretTodoAppInsightsConnectionString 'components/kv-secret.bicep' = {
  name: 'kv-secret-todo-app-ai-connection-string'
  params: {
    keyVaultName: keyVault.name
    secretName: 'TODO-APP-INSIGHTS-CONNECTION-STRING'
    secretValue: todoAppInsights.properties.ConnectionString
  }
}

module kvSecretTodoAppInsightsInstrumentationKey 'components/kv-secret.bicep' = {
  name: 'kv-secret-todo-app-ai-instrumentation-key'
  params: {
    keyVaultName: keyVault.name
    secretName: 'TODO-APP-INSIGHTS-INSTRUMENTATION-KEY'
    secretValue: todoAppInsights.properties.InstrumentationKey
  }
}

module rbacKVSecretTodoDSUri './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-todo-ds-url'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: todoAppUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(todoAppUserManagedIdentity.properties.principalId, kvSecretTodoAppSpringDSURI.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: kvSecretTodoAppSpringDSURI.outputs.kvSecretName
  }
}

module rbacKVSecretTodoAppDbUserName './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-todo-app-db-user'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: todoAppUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(todoAppUserManagedIdentity.properties.principalId, kvSecretTodoAppDbUserName.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: kvSecretTodoAppDbUserName.outputs.kvSecretName
  }
}

module rbacKVSecretTodoAppAppInsightsConStr './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-todo-app-insights-con-str'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: todoAppUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(todoAppUserManagedIdentity.properties.principalId, kvSecretTodoAppInsightsConnectionString.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: kvSecretTodoAppInsightsConnectionString.outputs.kvSecretName
  }
}

module rbacKVSecretTodoAppAppInsightsInstrKey './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-todo-app-insights-instr-key'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: todoAppUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(todoAppUserManagedIdentity.properties.principalId, kvSecretTodoAppInsightsInstrumentationKey.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: kvSecretTodoAppInsightsInstrumentationKey.outputs.kvSecretName
  }
}

module rbacContainerRegistryACRPull 'components/role-assignment-container-registry.bicep' = {
  name: 'deployment-rbac-container-registry-acr-pull'
  scope: resourceGroup(containerRegistrySubscriptionIdVar, containerRegistryRGVar)
  params: {
    containerRegistryName: containerRegistryName
    roleDefinitionId: acrPullRole.id
    principalId: todoAppUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(todoAppUserManagedIdentity.properties.principalId, containerRegistry.id, acrPullRole.id)
  }
}

@description('This is the built-in AcrPull role. See https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#acrpull')
resource acrPullRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: resourceGroup()
  name: '7f951dda-4ed3-4680-a7ca-43fe172d538d'
}

@description('This is the built-in Key Vault Secrets User role. See https://docs.microsoft.com/en-gb/azure/role-based-access-control/built-in-roles#key-vault-secrets-user')
resource keyVaultSecretsUser 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: resourceGroup()
  name: '4633458b-17de-408a-b874-0445c86b69e6'
}

output todoAppUserManagedIdentityName string = todoAppUserManagedIdentity.name
output todoAppUserManagedIdentityPrincipalId string = todoAppUserManagedIdentity.properties.principalId
output todoAppUserManagedIdentityClientId string = todoAppUserManagedIdentity.properties.clientId
output todoAppDbUserName string = todoAppDbUserName
