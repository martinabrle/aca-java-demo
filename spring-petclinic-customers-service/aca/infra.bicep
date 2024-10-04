param acaName string
param acaTags string

param pgsqlName string
param pgsqlPetClinicDbName string = 'petclinicdb'
param petClinicCustsSvcDbUserName string = 'petclinicadmin'

param petClinicCustsSvcUserManagedIdentityName string = '${acaName}-pet-clinic-custs-identity'

param containerRegistryName string = replace(replace(acaName,'_', ''),'-','')
param containerRegistrySubscriptionId string = subscription().id
param containerRegistryRG string = resourceGroup().name

var containerRegistrySubscriptionIdVar = (containerRegistrySubscriptionId == '') ? subscription().id : containerRegistrySubscriptionId
var containerRegistryRGVar = (containerRegistryRG == '') ? resourceGroup().name : containerRegistryRG

var acaTagsArray = json(acaTags)

param location string

resource petClinicCustsSvcUserManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: petClinicCustsSvcUserManagedIdentityName
  location: location
  tags: acaTagsArray
}

resource petClinicAppInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: '${acaName}-pet-clinic-ai'
}

resource keyVault 'Microsoft.KeyVault/vaults@2024-04-01-preview' existing = {
  name: '${acaName}-kv'
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' existing = {
  name: containerRegistryName
  scope: resourceGroup(containerRegistrySubscriptionIdVar, containerRegistryRGVar)
}


module kvSecretPetClinicAppInsightsConnectionString 'components/kv-secret.bicep' = {
  name: 'kv-secret-pet-clinic-ai-connection-string'
  params: {
    keyVaultName: keyVault.name
    secretName: 'PET-CLINIC-APP-INSIGHTS-CONNECTION-STRING'
    secretValue: petClinicAppInsights.properties.ConnectionString
  }
}

module kvSecretPetClinicAppInsightsInstrumentationKey 'components/kv-secret.bicep' = {
  name: 'kv-secret-pet-clinic-ai-instrumentation-key'
  params: {
    keyVaultName: keyVault.name
    secretName: 'PET-CLINIC-APP-INSIGHTS-INSTRUMENTATION-KEY'
    secretValue: petClinicAppInsights.properties.InstrumentationKey
  }
}

module kvSecretPetClinicAppSpringDSURL 'components/kv-secret.bicep' = {
  name: 'kv-secret-pet-clinic-app-ds-url'
  params: {
    keyVaultName: keyVault.name
    secretName: 'PET-CLINIC-APP-SPRING-DATASOURCE-URL'
    secretValue: 'jdbc:postgresql://${pgsqlName}.postgres.database.azure.com:5432/${pgsqlPetClinicDbName}'
  }
}

module kvSecretPetClinicCustsSvcDbUserName 'components/kv-secret.bicep' = {
  name: 'kv-secret-pet-clinic-custs-svc-ds-username'
  params: {
    keyVaultName: keyVault.name
    secretName: 'PET-CLINIC-CUSTS-SVC-SPRING-DS-USER'
    secretValue: petClinicCustsSvcDbUserName

  }
}

module rbacKVSecretPetClinicAppInsightsConStr './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-insights-con-str'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: petClinicCustsSvcUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicCustsSvcUserManagedIdentity.properties.principalId, kvSecretPetClinicAppInsightsConnectionString.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: kvSecretPetClinicAppInsightsConnectionString.outputs.kvSecretName
  }
}

module rbacKVSecretPetClinicAppInsightsInstrKey './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-insights-instr-key'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: petClinicCustsSvcUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicCustsSvcUserManagedIdentity.properties.principalId, kvSecretPetClinicAppInsightsInstrumentationKey.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: kvSecretPetClinicAppInsightsInstrumentationKey.outputs.kvSecretName
  }
}

module rbacKVSecretPetCustsSvcDSUri './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-pet-custs-ds-url'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: petClinicCustsSvcUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicCustsSvcUserManagedIdentity.properties.principalId, kvSecretPetClinicAppSpringDSURL.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: kvSecretPetClinicAppSpringDSURL.outputs.kvSecretName
  }
}

module rbacKVSecretPetCustsSvcDBUSer './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-pet-custs-svc-db-user'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: petClinicCustsSvcUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicCustsSvcUserManagedIdentity.properties.principalId, kvSecretPetClinicCustsSvcDbUserName.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: kvSecretPetClinicCustsSvcDbUserName.outputs.kvSecretName
  }
}

module rbacContainerRegistryACRPull 'components/role-assignment-container-registry.bicep' = {
  name: 'deployment-rbac-container-registry-acr-pull'
  scope: resourceGroup(containerRegistrySubscriptionIdVar, containerRegistryRGVar)
  params: {
    containerRegistryName: containerRegistryName
    roleDefinitionId: acrPullRole.id
    principalId: petClinicCustsSvcUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicCustsSvcUserManagedIdentity.properties.principalId, containerRegistry.id, acrPullRole.id)
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

output petClinicCustsSvcUserManagedIdentityName string = petClinicCustsSvcUserManagedIdentity.name
output petClinicCustsSvcUserManagedIdentityPrincipalId string = petClinicCustsSvcUserManagedIdentity.properties.principalId
output petClinicCustsSvcUserManagedIdentityClientId string = petClinicCustsSvcUserManagedIdentity.properties.clientId

