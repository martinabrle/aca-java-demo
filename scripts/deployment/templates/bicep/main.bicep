param acaName string

param acaTags string = '{ "CostCentre": "DEV", "Department": "RESEARCH", "WorkloadType": "TEST" }'

param pgsqlName string = '${replace(acaName,'_','-')}-pgsql'
param pgsqlAADAdminGroupName string
param pgsqlAADAdminGroupObjectId string
param pgsqlTodoAppDbName string
param todoAppDbUserName string = 'todoapp'
param pgsqlPetClinicDbName string
param petClinicCustsSvcDbUserName string = 'petcustssvc'
param petClinicVetsSvcDbUserName string = 'petvetssvc'
param petClinicVisitsSvcDbUserName string = 'petvisitssvc'

param pgsqlSubscriptionId string = subscription().id
param pgsqlRG string = resourceGroup().name
param pgsqlTags string = acaTags

param todoAppUserManagedIdentityName string = '${acaName}-todo-app-identity'
param petClinicAppUserManagedIdentityName string = '${acaName}-pet-clinic-app-identity'
param petClinicConfigSvcUserManagedIdentityName string = '${acaName}-pet-clinic-config-identity'
param petClinicCustsSvcUserManagedIdentityName string = '${acaName}-pet-clinic-custs-identity'
param petClinicVetsSvcUserManagedIdentityName string = '${acaName}-pet-clinic-vets-identity'
param petClinicVisitsSvcUserManagedIdentityName string = '${acaName}-pet-clinic-visits-identity'

@description('URI of the GitHub config repo, for example: https://github.com/spring-petclinic/spring-petclinic-microservices-config')
param petClinicGitConfigRepoUri string
@description('User name used to access the GitHub config repo')
param petClinicGitConfigRepoUserName string
@secure()
@description('Password (PAT) used to access the GitHub config repo')
param petClinicGitConfigRepoPassword string

@description('Log Analytics Workspace\'s name')
param logAnalyticsName string = '${replace(acaName, '_', '-')}-${location}'
@description('Subscription ID of the Log Analytics Workspace')
param logAnalyticsSubscriptionId string = subscription().id
@description('Resource Group of the Log Analytics Workspace')
param logAnalyticsRG string = resourceGroup().name
@description('Resource Tags to apply at the Log Analytics Workspace\'s level')
param logAnalyticsTags string = acaTags

param containerRegistryName string = replace(replace(acaName,'_', ''),'-','')
param containerRegistrySubscriptionId string = subscription().id
param containerRegistryRG string = resourceGroup().name
param containerRegistryTags string = acaTags

param dnsZoneName string = acaName
param parentDnsZoneName string = ''
param parentDnsZoneSubscriptionId string = ''
param parentDnsZoneRG string = ''
param parentDnsZoneTags string = ''

param petClinicDnsZoneName string = ''

var acaTagsVar = (acaTags == '') ? '{ "CostCentre": "DEV", "Department": "RESEARCH", "WorkloadType": "TEST" }' : acaTags

var pgsqlSubscriptionIdVar = (pgsqlSubscriptionId == '') ? subscription().id : pgsqlSubscriptionId
var pgsqlRGVar = (pgsqlRG == '') ? resourceGroup().name : pgsqlRG
var pgsqlTagsVar = (pgsqlTags == '') ? acaTagsVar : pgsqlTags

var containerRegistrySubscriptionIdVar = (containerRegistrySubscriptionId == '') ? subscription().id : containerRegistrySubscriptionId
var containerRegistryRGVar = (containerRegistryRG == '') ? resourceGroup().name : containerRegistryRG
var containerRegistryTagsVar = (containerRegistryTags == '') ? acaTagsVar : containerRegistryTags

var logAnalyticsSubscriptionIdVar = (logAnalyticsSubscriptionId == '') ? subscription().id : logAnalyticsSubscriptionId
var logAnalyticsRGVar = (logAnalyticsRG == '') ? resourceGroup().name : logAnalyticsRG
var logAnalyticsTagsVar = (logAnalyticsTags == '') ? acaTagsVar : logAnalyticsTags

var parentDnsZoneSubscriptionIdVar = (parentDnsZoneSubscriptionId == '') ? subscription().id : parentDnsZoneSubscriptionId
var parentDnsZoneRGVar = (parentDnsZoneRG == '') ? resourceGroup().name : parentDnsZoneRG
var parentDnsZoneTagsVar = (parentDnsZoneTags == '') ? acaTagsVar : parentDnsZoneTags

var acaTagsArray = json(acaTagsVar)
var pgsqlTagsArray = json(pgsqlTagsVar)
var containerRegistryTagsArray = json(containerRegistryTagsVar)
var logAnalyticsTagsArray = json(logAnalyticsTagsVar)
var parentDnsZoneTagsArray = json(parentDnsZoneTagsVar)

param location string


resource todoAppUserManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: todoAppUserManagedIdentityName
  location: location
  tags: acaTagsArray
}

resource petClinicAppUserManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: petClinicAppUserManagedIdentityName
  location: location
  tags: acaTagsArray
}

resource petClinicConfigSvcUserManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: petClinicConfigSvcUserManagedIdentityName
  location: location
  tags: acaTagsArray
}

resource petClinicCustsSvcUserManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: petClinicCustsSvcUserManagedIdentityName
  location: location
  tags: acaTagsArray
}

resource petClinicVetsSvcUserManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: petClinicVetsSvcUserManagedIdentityName
  location: location
  tags: acaTagsArray
}

resource petClinicVisitsSvcUserManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: petClinicVisitsSvcUserManagedIdentityName
  location: location
  tags: acaTagsArray
}

module logAnalytics 'components/log-analytics.bicep' = {
  name: 'log-analytics'
  scope: resourceGroup(logAnalyticsSubscriptionIdVar, logAnalyticsRGVar)
  params: {
    logAnalyticsName: logAnalyticsName
    location: location
    tagsArray: logAnalyticsTagsArray
  }
}

module todoAppInsights 'components/app-insights.bicep' = {
  name: 'todo-app-insights'
  params: {
    name: '${acaName}-todo-ai'
    location: location
    tagsArray: acaTagsArray
    logAnalyticsStringId: logAnalytics.outputs.logAnalyticsWorkspaceId
  }
}

module petClinicAppInsights 'components/app-insights.bicep' = {
  name: 'pet-clinic-app-insights'
  params: {
    name: '${acaName}-pet-clinic-ai'
    location: location
    tagsArray: acaTagsArray
    logAnalyticsStringId: logAnalytics.outputs.logAnalyticsWorkspaceId
  }
}

// resource petClinicCustsSvcUserManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
//   name: petClinicCustsSvcUserManagedIdentityName
//   location: location
//   tags: acaTagsArray
// }

module pgsql './components/pgsql.bicep' = {
  name: 'pgsql'
  scope: resourceGroup(pgsqlSubscriptionIdVar, pgsqlRGVar)
  params: {
    name: pgsqlName
    dbServerAADAdminGroupName: pgsqlAADAdminGroupName
    dbServerAADAdminGroupObjectId: pgsqlAADAdminGroupObjectId
    petClinicDBName: pgsqlPetClinicDbName
    todoDBName: pgsqlTodoAppDbName
    location: location
    tagsArray: pgsqlTagsArray
    logAnalyticsWorkspaceId: logAnalytics.outputs.logAnalyticsWorkspaceId
  }
}

module containerRegistry './components/container-registry.bicep' = {
  name: 'container-registry'
  scope: resourceGroup(containerRegistrySubscriptionIdVar, containerRegistryRGVar)
  params: {
    name: containerRegistryName
    location: location
    tagsArray: containerRegistryTagsArray
    logAnalyticsWorkspaceId: logAnalytics.outputs.logAnalyticsWorkspaceId
  }
}

module keyVault 'components/kv.bicep' = {
  name: 'keyvault'
  params: {
    name: '${acaName}-kv'
    location: location
    tagsArray: acaTagsArray
    logAnalyticsWorkspaceId: logAnalytics.outputs.logAnalyticsWorkspaceId
  }
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

module rbacKVSecretCustSvcAppInsightsInstrKey './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-cust-svc-insights-instr-key'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: petClinicCustsSvcUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicCustsSvcUserManagedIdentity.properties.principalId, kvSecretPetClinicAppInsightsInstrumentationKey.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: kvSecretPetClinicAppInsightsInstrumentationKey.outputs.kvSecretName
  }
}

module rbacKVSecretConfigSvcAppInsightsConStr './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-config-svc-insights-con-str'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: petClinicConfigSvcUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicConfigSvcUserManagedIdentity.properties.principalId, kvSecretPetClinicAppInsightsConnectionString.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: kvSecretPetClinicAppInsightsConnectionString.outputs.kvSecretName
  }
}

module rbacKVSecretSvcAppInsightsInstrKey './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-config-svc-insights-instr-key'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: petClinicConfigSvcUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicConfigSvcUserManagedIdentity.properties.principalId, kvSecretPetClinicAppInsightsInstrumentationKey.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: kvSecretPetClinicAppInsightsInstrumentationKey.outputs.kvSecretName
  }
}

module rbacKVSecretConfigSvcGitRepoURI './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-config-svc-git-repo-uri'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: petClinicConfigSvcUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicConfigSvcUserManagedIdentity.properties.principalId, kvSecretPetClinicConfigRepoURI.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: kvSecretPetClinicConfigRepoURI.outputs.kvSecretName
  }
}

module rbacKVSecretConfigSvcGitRepoUser './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-config-svc-git-repo-user'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: petClinicConfigSvcUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicConfigSvcUserManagedIdentity.properties.principalId, kvSecretPetClinicConfigRepoUserName.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: kvSecretPetClinicConfigRepoUserName.outputs.kvSecretName
  }
}

module rbacKVSecretConfigSvcGitRepoPassword './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-config-svc-git-repo-password'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: petClinicConfigSvcUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicConfigSvcUserManagedIdentity.properties.principalId, kvSecretPetClinicConfigRepoPassword.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: kvSecretPetClinicConfigRepoPassword.outputs.kvSecretName
  }
}

module rbacContainerRegistryConfigSvcACRPull 'components/role-assignment-container-registry.bicep' = {
  name: 'rbac-container-registry-config-svc-acr-pull'
  scope: resourceGroup(containerRegistrySubscriptionIdVar, containerRegistryRGVar)
  params: {
    containerRegistryName: containerRegistryName
    roleDefinitionId: acrPullRole.id
    principalId: petClinicConfigSvcUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicConfigSvcUserManagedIdentity.properties.principalId, containerRegistry.id, acrPullRole.id)
  }
}

module rbacKVSecretVetsSvcAppInsightsConStr './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-vets-svc-insights-con-str'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: petClinicVetsSvcUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicVetsSvcUserManagedIdentity.properties.principalId, kvSecretPetClinicAppInsightsConnectionString.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: kvSecretPetClinicAppInsightsConnectionString.outputs.kvSecretName
  }
}

module rbacKVSecretVetsSvcAppInsightsInstrKey './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-vets-svc-insights-instr-key'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: petClinicVetsSvcUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicVetsSvcUserManagedIdentity.properties.principalId, kvSecretPetClinicAppInsightsInstrumentationKey.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: kvSecretPetClinicAppInsightsInstrumentationKey.outputs.kvSecretName
  }
}

module rbacKVSecretVetsSvcDSUri './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-vets-svc-ds-uri'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: petClinicVetsSvcUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicVetsSvcUserManagedIdentity.properties.principalId, kvSecretPetClinicAppSpringDSURL.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: kvSecretPetClinicAppSpringDSURL.outputs.kvSecretName
  }
}

module rbacKVSecretVetsSvcDBUSer './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-vets-svc-db-user'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: petClinicVetsSvcUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicVetsSvcUserManagedIdentity.properties.principalId, kvSecretPetClinicVetsSvcDbUserName.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: kvSecretPetClinicVetsSvcDbUserName.outputs.kvSecretName
  }
}

module rbacContainerRegistryVetsSvcACRPull 'components/role-assignment-container-registry.bicep' = {
  name: 'rbac-container-registry-vets-svc-acr-pull'
  scope: resourceGroup(containerRegistrySubscriptionIdVar, containerRegistryRGVar)
  params: {
    containerRegistryName: containerRegistryName
    roleDefinitionId: acrPullRole.id
    principalId: petClinicVetsSvcUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicVetsSvcUserManagedIdentity.properties.principalId, containerRegistry.id, acrPullRole.id)
  }
}

module rbacKVSecretCustsSvcDSUri './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-custs-svc-ds-uri'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: petClinicCustsSvcUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicCustsSvcUserManagedIdentity.properties.principalId, kvSecretPetClinicAppSpringDSURL.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: kvSecretPetClinicAppSpringDSURL.outputs.kvSecretName
  }
}

module rbacKVSecretCustsSvcDBUSer './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-custs-svc-db-user'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: petClinicCustsSvcUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicCustsSvcUserManagedIdentity.properties.principalId, kvSecretPetClinicCustsSvcDbUserName.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: kvSecretPetClinicCustsSvcDbUserName.outputs.kvSecretName
  }
}

module rbacContainerRegistryCustsSvcACRPull 'components/role-assignment-container-registry.bicep' = {
  name: 'rbac-container-registry-custs-svc-acr-pull'
  scope: resourceGroup(containerRegistrySubscriptionIdVar, containerRegistryRGVar)
  params: {
    containerRegistryName: containerRegistryName
    roleDefinitionId: acrPullRole.id
    principalId: petClinicCustsSvcUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicCustsSvcUserManagedIdentity.properties.principalId, containerRegistry.id, acrPullRole.id)
  }
}

module rbacKVSecretVisitsSvcAppInsightsConStr './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-visits-svc-insights-con-str'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: petClinicVisitsSvcUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicVisitsSvcUserManagedIdentity.properties.principalId, kvSecretPetClinicAppInsightsConnectionString.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: kvSecretPetClinicAppInsightsConnectionString.outputs.kvSecretName
  }
}

module rbacKVSecretVisitsSvcAppInsightsInstrKeyVisit './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-visits-svc-insights-instr-key'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: petClinicVisitsSvcUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicVisitsSvcUserManagedIdentity.properties.principalId, kvSecretPetClinicAppInsightsInstrumentationKey.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: kvSecretPetClinicAppInsightsInstrumentationKey.outputs.kvSecretName
  }
}

module rbacKVSecretVisitsSvcDSUri './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-visits-svc-ds-uri'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: petClinicVisitsSvcUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicVisitsSvcUserManagedIdentity.properties.principalId, kvSecretPetClinicAppSpringDSURL.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: kvSecretPetClinicAppSpringDSURL.outputs.kvSecretName
  }
}

module rbacKVSecretVisitsSvcDBUSer './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-visits-svc-db-user'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: petClinicVisitsSvcUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicVisitsSvcUserManagedIdentity.properties.principalId, kvSecretPetClinicVisitsSvcDbUserName.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: kvSecretPetClinicVisitsSvcDbUserName.outputs.kvSecretName
  }
}

module rbacContainerRegistryVisitsSvcACRPull 'components/role-assignment-container-registry.bicep' = {
  name: 'rbac-container-registry-visits-svc-acr-pull'
  scope: resourceGroup(containerRegistrySubscriptionIdVar, containerRegistryRGVar)
  params: {
    containerRegistryName: containerRegistryName
    roleDefinitionId: acrPullRole.id
    principalId: petClinicVisitsSvcUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicVisitsSvcUserManagedIdentity.properties.principalId, containerRegistry.id, acrPullRole.id)
  }
}

module rbacKVSecretTodoDSUri './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-todo-app-ds-uri'
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

module rbacKVSecretTodoAppInsightsConStr './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-todo-app-insights-con-str'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: todoAppUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(todoAppUserManagedIdentity.properties.principalId, kvSecretTodoAppInsightsConnectionString.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: kvSecretTodoAppInsightsConnectionString.outputs.kvSecretName
  }
}

module rbacKVSecretTodoAppInsightsInstrKey './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-todo-app-insights-instr-key'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: todoAppUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(todoAppUserManagedIdentity.properties.principalId, kvSecretTodoAppInsightsInstrumentationKey.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: kvSecretTodoAppInsightsInstrumentationKey.outputs.kvSecretName
  }
}

module rbacContainerRegistryTodoAppACRPull 'components/role-assignment-container-registry.bicep' = {
  name: 'rbac-container-registry-todo-app-acr-pull'
  scope: resourceGroup(containerRegistrySubscriptionIdVar, containerRegistryRGVar)
  params: {
    containerRegistryName: containerRegistryName
    roleDefinitionId: acrPullRole.id
    principalId: todoAppUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(todoAppUserManagedIdentity.properties.principalId, containerRegistry.id, acrPullRole.id)
  }
}


module rbacKVSecretPetAppClinicAppInsightsConStr './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-pet-app-insights-con-str'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: petClinicAppUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicAppUserManagedIdentity.properties.principalId, kvSecretPetClinicAppInsightsConnectionString.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: kvSecretPetClinicAppInsightsConnectionString.outputs.kvSecretName
  }
}

module rbacKVSecretPetAppClinicAppInsightsInstrKey './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-pet-app-insights-instr-key'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: petClinicAppUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicAppUserManagedIdentity.properties.principalId, kvSecretPetClinicAppInsightsInstrumentationKey.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.name
    kvSecretName: kvSecretPetClinicAppInsightsInstrumentationKey.outputs.kvSecretName
  }
}

module rbacContainerRegistryPetAppACRPull 'components/role-assignment-container-registry.bicep' = {
  name: 'rbac-container-registry-pet-app-acr-pull'
  scope: resourceGroup(containerRegistrySubscriptionIdVar, containerRegistryRGVar)
  params: {
    containerRegistryName: containerRegistryName
    roleDefinitionId: acrPullRole.id
    principalId: petClinicAppUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicAppUserManagedIdentity.properties.principalId, containerRegistry.id, acrPullRole.id)
  }
}

module kvSecretPetClinicConfigRepoURI 'components/kv-secret.bicep' = {
  name: 'kv-secret-pet-clinic-config-repo-uri'
  params: {
    keyVaultName: keyVault.outputs.keyVaultName
    secretName: 'PET-CLINIC-CONFIG-SVC-GIT-REPO-URI'
    secretValue: petClinicGitConfigRepoUri
  }
}

module kvSecretPetClinicConfigRepoUserName 'components/kv-secret.bicep' = {
  name: 'kv-secret-pet-clinic-config-repo-user-name'
  params: {
    keyVaultName: keyVault.outputs.keyVaultName
    secretName: 'PET-CLINIC-CONFIG-SVC-GIT-REPO-USERNAME'
    secretValue: petClinicGitConfigRepoUserName
  }
}

module kvSecretPetClinicConfigRepoPassword 'components/kv-secret.bicep' = {
  name: 'kv-secret-pet-clinic-config-repo-password'
  params: {
    keyVaultName: keyVault.outputs.keyVaultName
    secretName: 'PET-CLINIC-CONFIG-SVC-GIT-REPO-PASSWORD'
    secretValue: petClinicGitConfigRepoPassword
  }
}

module kvSecretPetClinicAppSpringDSURL 'components/kv-secret.bicep' = {
  name: 'kv-secret-pet-clinic-app-ds-url'
  params: {
    keyVaultName: keyVault.outputs.keyVaultName
    secretName: 'PET-CLINIC-APP-SPRING-DATASOURCE-URL'
    secretValue: 'jdbc:postgresql://${pgsqlName}.postgres.database.azure.com:5432/${pgsqlPetClinicDbName}'
  }
}

module kvSecretPetClinicVetsSvcDbUserName 'components/kv-secret.bicep' = {
  name: 'kv-secret-pet-clinic-vets-svc-ds-username'
  params: {
    keyVaultName: keyVault.outputs.keyVaultName
    secretName: 'PET-CLINIC-VETS-SVC-SPRING-DS-USER'
    secretValue: petClinicVetsSvcDbUserName
  }
}

module kvSecretPetClinicVisitsSvcDbUserName 'components/kv-secret.bicep' = {
  name: 'kv-secret-pet-clinic-visits-svc-ds-username'
  params: {
    keyVaultName: keyVault.outputs.keyVaultName
    secretName: 'PET-CLINIC-VISITS-SVC-SPRING-DS-USER'
    secretValue: petClinicVisitsSvcDbUserName
  }
}

module kvSecretPetClinicAppInsightsConnectionString 'components/kv-secret.bicep' = {
  name: 'kv-secret-pet-clinic-ai-connection-string'
  params: {
    keyVaultName: keyVault.outputs.keyVaultName
    secretName: 'PET-CLINIC-APP-INSIGHTS-CONNECTION-STRING'
    secretValue: petClinicAppInsights.outputs.appInsightsConnectionString
  }
}

module kvSecretPetClinicAppInsightsInstrumentationKey 'components/kv-secret.bicep' = {
  name: 'kv-secret-pet-clinic-ai-instrumentation-key'
  params: {
    keyVaultName: keyVault.outputs.keyVaultName
    secretName: 'PET-CLINIC-APP-INSIGHTS-INSTRUMENTATION-KEY'
    secretValue: petClinicAppInsights.outputs.appInsightsInstrumentationKey
  }
}

module kvSecretTodoAppInsightsConnectionString 'components/kv-secret.bicep' = {
  name: 'kv-secret-todo-app-ai-connection-string'
  params: {
    keyVaultName: keyVault.name
    secretName: 'TODO-APP-INSIGHTS-CONNECTION-STRING'
    secretValue: todoAppInsights.outputs.appInsightsConnectionString
  }
}

module kvSecretTodoAppInsightsInstrumentationKey 'components/kv-secret.bicep' = {
  name: 'kv-secret-todo-app-ai-instrumentation-key'
  params: {
    keyVaultName: keyVault.name
    secretName: 'TODO-APP-INSIGHTS-INSTRUMENTATION-KEY'
    secretValue: todoAppInsights.outputs.appInsightsInstrumentationKey
  }
}

module acaEnvironment 'components/aca-environment.bicep' = {
  name: 'aca-environment'
  params: {
    name: acaName
    logAnalyticsWorkspaceName: logAnalyticsName
    logAnalyticsWorkspaceRG: logAnalyticsRGVar
    logAnalyticsWorkspaceSubscriptionId: logAnalyticsSubscriptionIdVar
    location: location
    tagsArray: acaTagsArray
  }
}

module dnsZone './components/dns-zone.bicep' = if (!empty(dnsZoneName)) {
  name: 'child-dns-zone'
  params: {
    zoneName: dnsZoneName
    parentZoneName: parentDnsZoneName
    parentZoneRG: parentDnsZoneRGVar
    parentZoneSubscriptionId: parentDnsZoneSubscriptionIdVar
    parentZoneTagsArray: parentDnsZoneTagsArray
    tagsArray: acaTagsArray
  }
}

module dnsZonePetClinic 'components/dns-zone.bicep' = if (!empty(dnsZoneName) && !empty(petClinicDnsZoneName)) {
  name: 'child-dns-zone-pet-clinic'
  params: {
    zoneName: petClinicDnsZoneName
    parentZoneName: '${dnsZoneName}.${parentDnsZoneName}'
    parentZoneRG: resourceGroup().name
    parentZoneSubscriptionId: subscription().subscriptionId
    parentZoneTagsArray: acaTagsArray
    tagsArray: acaTagsArray
  }
}

@description('This is the built-in Key Vault Secrets User role. See https://docs.microsoft.com/en-gb/azure/role-based-access-control/built-in-roles#key-vault-secrets-user')
resource keyVaultSecretsUser 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: resourceGroup()
  name: '4633458b-17de-408a-b874-0445c86b69e6'
}

@description('This is the built-in AcrPull role. See https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#acrpull')
resource acrPullRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: resourceGroup()
  name: '7f951dda-4ed3-4680-a7ca-43fe172d538d'
}

// output petClinicAppUserManagedIdentityName string = petClinicAppUserManagedIdentity.name
// output petClinicAppUserManagedIdentityPrincipalId string = petClinicAppUserManagedIdentity.properties.principalId
// output petClinicAppUserManagedIdentityClientId string = petClinicAppUserManagedIdentity.properties.clientId

// output petClinicConfigSvcUserManagedIdentityName string = petClinicConfigSvcUserManagedIdentity.name
// output petClinicConfigSvcUserManagedIdentityPrincipalId string = petClinicConfigSvcUserManagedIdentity.properties.principalId
// output petClinicConfigSvcUserManagedIdentityClientId string = petClinicConfigSvcUserManagedIdentity.properties.clientId

// output petClinicCustsSvcUserManagedIdentityName string = petClinicCustsSvcUserManagedIdentity.name
// output petClinicCustsSvcUserManagedIdentityPrincipalId string = petClinicCustsSvcUserManagedIdentity.properties.principalId
// output petClinicCustsSvcUserManagedIdentityClientId string = petClinicCustsSvcUserManagedIdentity.properties.clientId
// output petClinicCustsSvcDbUserName string = petClinicCustsSvcDbUserName

// output petClinicVetsSvcUserManagedIdentityName string = petClinicVetsSvcUserManagedIdentity.name
// output petClinicVetsSvcUserManagedIdentityPrincipalId string = petClinicVetsSvcUserManagedIdentity.properties.principalId
// output petClinicVetsSvcUserManagedIdentityClientId string = petClinicVetsSvcUserManagedIdentity.properties.clientId
// output petClinicVetsSvcDbUserName string = petClinicVetsSvcDbUserName

// output petClinicVisitsSvcUserManagedIdentityName string = petClinicVisitsSvcUserManagedIdentity.name
// output petClinicVisitsSvcUserManagedIdentityPrincipalId string = petClinicVisitsSvcUserManagedIdentity.properties.principalId
// output petClinicVisitsSvcUserManagedIdentityClientId string = petClinicVisitsSvcUserManagedIdentity.properties.clientId
// output petClinicVisitsSvcDbUserName string = petClinicVisitsSvcDbUserName
