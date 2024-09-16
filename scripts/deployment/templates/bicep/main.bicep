// Secrets KeyVault integration https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-driver
// Workload identities https://learn.microsoft.com/en-us/azure/aks/workload-identity-overview#how-it-works

param aksName string
param aksAdminGroupObjectId string
param aksTags string

param pgsqlName string = '${replace(aksName,'_','-')}-pgsql'
param pgsqlAADAdminGroupName string
param pgsqlAADAdminGroupObjectId string
param pgsqlTodoAppDbName string
param todoAppDbUserName string // = 'todo_app' - moved to GH secrets
param pgsqlPetClinicDbName string
param petClinicCustsSvcDbUserName string // = 'pet_clinic_custs_svc'
param petClinicVetsSvcDbUserName string // = 'pet_clinic_vets_svc'
param petClinicVisitsSvcDbUserName string // = 'pet_clinic_visits_svc'

param pgsqlSubscriptionId string = subscription().id
param pgsqlRG string = resourceGroup().name
param pgsqlTags string = aksTags

param todoAppUserManagedIdentityName string = '${aksName}-todo-app-identity'
param petClinicAppUserManagedIdentityName string = '${aksName}-pet-clinic-app-identity'
param petClinicConfigSvcUserManagedIdentityName string = '${aksName}-pet-clinic-config-identity'
param petClinicCustsSvcUserManagedIdentityName string = '${aksName}-pet-clinic-custs-identity'
param petClinicVetsSvcUserManagedIdentityName string = '${aksName}-pet-clinic-vets-identity'
param petClinicVisitsSvcUserManagedIdentityName string = '${aksName}-pet-clinic-visits-identity'

@description('URI of the GitHub config repo, for example: https://github.com/spring-petclinic/spring-petclinic-microservices-config')
param petClinicGitConfigRepoUri string
@description('User name used to access the GitHub config repo')
param petClinicGitConfigRepoUserName string
@secure()
@description('Password (PAT) used to access the GitHub config repo')
param petClinicGitConfigRepoPassword string

@description('Log Analytics Workspace\'s name')
param logAnalyticsName string = '${replace(aksName, '_', '-')}-${location}'
@description('Subscription ID of the Log Analytics Workspace')
param logAnalyticsSubscriptionId string = subscription().id
@description('Resource Group of the Log Analytics Workspace')
param logAnalyticsRG string = resourceGroup().name
@description('Resource Tags to apply at the Log Analytics Workspace\'s level')
param logAnalyticsTags string = aksTags

param containerRegistryName string = replace(replace(aksName,'_', ''),'-','')
param containerRegistrySubscriptionId string = subscription().id
param containerRegistryRG string = resourceGroup().name
param containerRegistryTags string = aksTags

param dnsZoneName string = aksName
param parentDnsZoneName string = ''
param parentDnsZoneSubscriptionId string = ''
param parentDnsZoneRG string = ''
param parentDnsZoneTags string = ''

param todoAppDnsRecordName string = ''
param petClinicDnsRecordName string = ''
param petClinicAdminDnsRecordName string = 'admin.${petClinicDnsRecordName}' 
param petClinicGrafanaDnsRecordName string = 'grafana.${petClinicDnsRecordName}' 
param petClinicTracingServerDnsRecordName string = 'tracing-server.${petClinicDnsRecordName}' 

param sslCertKeyVaultSubscriptionId string = ''
param sslCertKeyVaultRG string = ''
param sslCertKeyVaultName string = ''
param sslCertKeyVaultToDoCertSecretName string = ''
param sslCertKeyVaultPetClinicCertSecretName string = ''

var pgsqlSubscriptionIdVar = (pgsqlSubscriptionId == '') ? subscription().id : pgsqlSubscriptionId
var pgsqlRGVar = (pgsqlRG == '') ? resourceGroup().name : pgsqlRG
var pgsqlTagsVar = (pgsqlTags == '') ? aksTags : pgsqlTags

var containerRegistrySubscriptionIdVar = (containerRegistrySubscriptionId == '') ? subscription().id : containerRegistrySubscriptionId
var containerRegistryRGVar = (containerRegistryRG == '') ? resourceGroup().name : containerRegistryRG
var containerRegistryTagsVar = (containerRegistryTags == '') ? aksTags : containerRegistryTags

var logAnalyticsSubscriptionIdVar = (logAnalyticsSubscriptionId == '') ? subscription().id : logAnalyticsSubscriptionId
var logAnalyticsRGVar = (logAnalyticsRG == '') ? resourceGroup().name : logAnalyticsRG
var logAnalyticsTagsVar = (logAnalyticsTags == '') ? aksTags : logAnalyticsTags

var parentDnsZoneSubscriptionIdVar = (parentDnsZoneSubscriptionId == '') ? subscription().id : parentDnsZoneSubscriptionId
var parentDnsZoneRGVar = (parentDnsZoneRG == '') ? resourceGroup().name : parentDnsZoneRG
var parentDnsZoneTagsVar = (parentDnsZoneTags == '') ? aksTags : parentDnsZoneTags

var aksTagsArray = json(aksTags)
var pgsqlTagsArray = json(pgsqlTagsVar)
var containerRegistryTagsArray = json(containerRegistryTagsVar)
var logAnalyticsTagsArray = json(logAnalyticsTagsVar)
var parentDnsZoneTagsArray = json(parentDnsZoneTagsVar)

var appGatewayName = '${aksName}-appgw'
var vnetName = '${aksName}-vnet'
var aksSubnetName = 'aks-default'
var appGatewaySubnetName = 'appgw-subnet'

param location string

resource todoAppUserManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: todoAppUserManagedIdentityName
  location: location
  tags: aksTagsArray
}

resource petClinicAppUserManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: petClinicAppUserManagedIdentityName
  location: location
  tags: aksTagsArray
}

resource petClinicConfigSvcUserManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: petClinicConfigSvcUserManagedIdentityName
  location: location
  tags: aksTagsArray
}

resource petClinicCustsSvcUserManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: petClinicCustsSvcUserManagedIdentityName
  location: location
  tags: aksTagsArray
}

resource petClinicVetsSvcUserManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: petClinicVetsSvcUserManagedIdentityName
  location: location
  tags: aksTagsArray
}

resource petClinicVisitsSvcUserManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: petClinicVisitsSvcUserManagedIdentityName
  location: location
  tags: aksTagsArray
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
    name: '${aksName}-todo-ai'
    location: location
    tagsArray: aksTagsArray
    logAnalyticsStringId: logAnalytics.outputs.logAnalyticsWorkspaceId
  }
}

module petClinicAppInsights 'components/app-insights.bicep' = {
  name: 'pet-clinic-app-insights'
  params: {
    name: '${aksName}-pet-clinic-ai'
    location: location
    tagsArray: aksTagsArray
    logAnalyticsStringId: logAnalytics.outputs.logAnalyticsWorkspaceId
  }
}

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
    name: '${aksName}-kv'
    location: location
    tagsArray: aksTagsArray
    logAnalyticsWorkspaceId: logAnalytics.outputs.logAnalyticsWorkspaceId
  }
}

module kvSecretTodoAppSpringDSURI 'components/kv-secret.bicep' = {
  name: 'kv-secret-todo-app-ds-uri'
  params: {
    keyVaultName: keyVault.outputs.keyVaultName
    secretName: 'TODO-SPRING-DATASOURCE-URL'
    secretValue: 'jdbc:postgresql://${pgsqlName}.postgres.database.azure.com:5432/${pgsqlTodoAppDbName}'
  }
}

module kvSecretTodoAppDbUserName 'components/kv-secret.bicep' = {
  name: 'kv-secret-todo-app-ds-username'
  params: {
    keyVaultName: keyVault.outputs.keyVaultName
    secretName: 'TODO-SPRING-DATASOURCE-USERNAME'
    secretValue: todoAppDbUserName
  }
}

module kvSecretTodoAppInsightsConnectionString 'components/kv-secret.bicep' = {
  name: 'kv-secret-todo-app-ai-connection-string'
  params: {
    keyVaultName: keyVault.outputs.keyVaultName
    secretName: 'TODO-APP-INSIGHTS-CONNECTION-STRING'
    secretValue: todoAppInsights.outputs.appInsightsConnectionString
  }
}

module kvSecretTodoAppInsightsInstrumentationKey 'components/kv-secret.bicep' = {
  name: 'kv-secret-todo-app-ai-instrumentation-key'
  params: {
    keyVaultName: keyVault.outputs.keyVaultName
    secretName: 'TODO-APP-INSIGHTS-INSTRUMENTATION-KEY'
    secretValue: todoAppInsights.outputs.appInsightsInstrumentationKey
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
  name: 'kv-secret-pet-clinic-config-repo-usern-ame'
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

module kvSecretPetClinicCustsSvcDbUserName 'components/kv-secret.bicep' = {
  name: 'kv-secret-pet-clinic-custs-svc-ds-username'
  params: {
    keyVaultName: keyVault.outputs.keyVaultName
    secretName: 'PET-CLINIC-CUSTS-SVC-SPRING-DS-USER'
    secretValue: petClinicCustsSvcDbUserName
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

module vnet 'components/vnet.bicep' = {
  name: vnetName
  params: {
    name: '${aksName}-vnet'
    aksSubnetName: aksSubnetName
    appGatewaySubnetName: appGatewaySubnetName
    location: location
    tagsArray: aksTagsArray
  }
}

resource sslCertKeyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = if (sslCertKeyVaultSubscriptionId != '') {
  name: sslCertKeyVaultName
  scope: resourceGroup(sslCertKeyVaultSubscriptionId, sslCertKeyVaultRG)
}

resource sslCertKeyVaultToDoCertSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' existing = if (!empty(sslCertKeyVaultSubscriptionId) != '' && !empty(sslCertKeyVaultToDoCertSecretName)) {
  parent: sslCertKeyVault
  name: sslCertKeyVaultToDoCertSecretName
}

resource sslCertKeyVaultPetClinicCertSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' existing = if (!empty(sslCertKeyVaultSubscriptionId) && !empty(sslCertKeyVaultPetClinicCertSecretName)) {
  parent: sslCertKeyVault
  name: sslCertKeyVaultPetClinicCertSecretName
}

module appGateway 'components/app-gateway.bicep' = {
  name: 'app-gateway'
  params: {
    name: appGatewayName
    vnetName: vnet.outputs.vnetName
    appGatewaySubnetName: vnet.outputs.appGatewaySubnetName
    sslCertKeyVaultToDoSecretUri: (!empty(sslCertKeyVaultSubscriptionId) != '' && !empty(sslCertKeyVaultToDoCertSecretName)) ? sslCertKeyVaultToDoCertSecret.properties.secretUri : ''
    sslCertKeyVaultPetClinicSecretUri: (!empty(sslCertKeyVaultSubscriptionId) && !empty(sslCertKeyVaultPetClinicCertSecretName)) ? sslCertKeyVaultPetClinicCertSecret.properties.secretUri : ''
    logAnalyticsWorkspaceId: logAnalytics.outputs.logAnalyticsWorkspaceId
    location: location
    tagsArray: aksTagsArray
  }
}

module aks 'components/aks.bicep' = {
  name: 'aks'
  params: {
    name: aksName
    vnetName: vnet.outputs.vnetName
    aksSubnetName: vnet.outputs.aksSubnetName
    //appGatewayName: appGateway.outputs.appGatewayName
    aksAdminGroupObjectId: aksAdminGroupObjectId
    logAnalyticsWorkspaceId: logAnalytics.outputs.logAnalyticsWorkspaceId
    location: location
    tagsArray: aksTagsArray
  }
}

module rbacContainerRegistryACRPull 'components/role-assignment-container-registry.bicep' = {
  name: 'deployment-rbac-container-registry-acr-pull'
  scope: resourceGroup(containerRegistrySubscriptionIdVar, containerRegistryRGVar)
  params: {
    containerRegistryName: containerRegistryName
    roleDefinitionId: acrPullRole.id
    principalId: aks.outputs.aksNodePoolIdentityPrincipalId //.aksSecretsProviderIdentityPrincipalId
    roleAssignmentNameGuid: guid(aks.outputs.aksNodePoolIdentityPrincipalId, containerRegistry.outputs.containerRegistryId, acrPullRole.id)
  }
}

module rbacKV 'components/role-assignment-kv.bicep' = {
  name: 'rbac-kv-aks-service'
  scope: resourceGroup()
  params: {
    kvName: keyVault.outputs.keyVaultName
    roleAssignmentNameGuid: guid(aks.outputs.aksSecretsProviderIdentityPrincipalId, keyVault.outputs.keyVaultId, keyVaultSecretsUser.id)
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: aks.outputs.aksSecretsProviderIdentityPrincipalId
  }
}

// AGIC's identity requires "Contributor" permission over Application Gateway.
module rbacAppGatewayAGICContributor 'components/rolle-assignment-app-gateway.bicep' = {
  scope: resourceGroup()
  name: 'rbac-app-gw-agic-contributor'
  params: {
    appGatewayName: appGateway.outputs.appGatewayName
    roleAssignmentNameGuid: guid(aks.outputs.agicIdentityPrincipalId, appGateway.outputs.appGatewayId, contributor.id) //aksIngressApplicationGatewayPrincipalId
    roleDefinitionId: managedIdentityOperator.id
    principalId: aks.outputs.agicIdentityPrincipalId //aksIngressApplicationGatewayPrincipalId
  }
}

// AGIC's identity requires "Reader" permission over Application Gateway's resource group.
module rbacAppGwAGICResourceGroupReader 'components/role-assignment-resource-group.bicep' = {
  name: 'rbac-app-gw-agic-rg-reader'
  scope: resourceGroup()
  params: {
    roleAssignmentNameGuid:  guid(aks.outputs.agicIdentityPrincipalId, resourceGroup().id, reader.id) //aksIngressApplicationGatewayPrincipalId
    roleDefinitionId: reader.id
    principalId: aks.outputs.agicIdentityPrincipalId //aksIngressApplicationGatewayPrincipalId
  }
}

// AGIC's identity requires "Managed Identity Operator" permission over the user assigned identity of Application Gateway.
module rbacAppGwAGIC 'components/role-assignment-user-managed-identity.bicep' = {
  name: 'rbac-app-gw-agic-mi-op'
  scope: resourceGroup()
  params: {
    userManagedIdentityName: appGateway.outputs.appGatewayIdentityName
    roleAssignmentNameGuid: guid(appGateway.outputs.appGatewayIdentityPrincipalId, aks.outputs.agicIdentityPrincipalId, managedIdentityOperator.id) //aksIngressApplicationGatewayPrincipalId
    roleDefinitionId: managedIdentityOperator.id
    principalId: aks.outputs.agicIdentityPrincipalId //aksIngressApplicationGatewayPrincipalId
  }
}

// When AGIC's identity does not have the write permission over Application Gateway RG, there are errors in the AKS log(?)
module rbacAppGwResourceGroupContributor 'components/role-assignment-resource-group.bicep' = {
  name: 'rbac-app-gw-rg-contributor'
  scope: resourceGroup()
  params: {
    roleAssignmentNameGuid: guid(aks.outputs.agicIdentityPrincipalId, resourceGroup().id, contributor.id) //aksIngressApplicationGatewayPrincipalId
    roleDefinitionId: contributor.id
    principalId: aks.outputs.agicIdentityPrincipalId
  }
}

module rbacKVSecretTodoDSUri './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-todo-ds-url'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: todoAppUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(todoAppUserManagedIdentity.properties.principalId, kvSecretTodoAppSpringDSURI.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.outputs.keyVaultName
    kvSecretName: kvSecretTodoAppSpringDSURI.outputs.kvSecretName
  }
}

module rbacKVSecretTodoAppDbUserName './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-todo-app-db-user'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: todoAppUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(todoAppUserManagedIdentity.properties.principalId, kvSecretTodoAppDbUserName.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.outputs.keyVaultName
    kvSecretName: kvSecretTodoAppDbUserName.outputs.kvSecretName
  }
}

module rbacKVSecretTodoAppAppInsightsConStr './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-todo-app-insights-con-str'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: todoAppUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(todoAppUserManagedIdentity.properties.principalId, kvSecretTodoAppInsightsConnectionString.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.outputs.keyVaultName
    kvSecretName: kvSecretTodoAppInsightsConnectionString.outputs.kvSecretName
  }
}

module rbacKVSecretTodoAppAppInsightsInstrKey './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-todo-app-insights-instr-key'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: todoAppUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(todoAppUserManagedIdentity.properties.principalId, kvSecretTodoAppInsightsInstrumentationKey.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.outputs.keyVaultName
    kvSecretName: kvSecretTodoAppInsightsInstrumentationKey.outputs.kvSecretName
  }
}

module rbacKVSecretPetAppInsightsConStr './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-pet-app-insights-con-str'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: petClinicAppUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicAppUserManagedIdentity.properties.principalId, kvSecretPetClinicAppInsightsConnectionString.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.outputs.keyVaultName
    kvSecretName: kvSecretPetClinicAppInsightsConnectionString.outputs.kvSecretName
  }
}

module rbacKVSecretPetAppInsightsInstrKey './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-pet-app-insights-instr-key'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: petClinicAppUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicAppUserManagedIdentity.properties.principalId, kvSecretPetClinicAppInsightsInstrumentationKey.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.outputs.keyVaultName
    kvSecretName: kvSecretPetClinicAppInsightsInstrumentationKey.outputs.kvSecretName
  }
}

module rbacKVSecretPetConfigSvcGitRepoURI './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-git-repo-uri'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: petClinicConfigSvcUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicConfigSvcUserManagedIdentity.properties.principalId, kvSecretPetClinicConfigRepoURI.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.outputs.keyVaultName
    kvSecretName: kvSecretPetClinicConfigRepoURI.outputs.kvSecretName
  }
}

module rbacKVSecretPetConfigSvcGitRepoUserName './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-git-repo-user'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: petClinicConfigSvcUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicConfigSvcUserManagedIdentity.properties.principalId, kvSecretPetClinicConfigRepoUserName.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.outputs.keyVaultName
    kvSecretName: kvSecretPetClinicConfigRepoUserName.outputs.kvSecretName
  }
}

module rbacKVSecretPetConfigSvcGitRepoPassword './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-git-repo-password'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: petClinicConfigSvcUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicConfigSvcUserManagedIdentity.properties.principalId, kvSecretPetClinicConfigRepoPassword.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.outputs.keyVaultName
    kvSecretName: kvSecretPetClinicConfigRepoPassword.outputs.kvSecretName
  }
}

module rbacKVSecretPetConfigSvcAppInsightsConStr './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-pet-config-app-insights-con-str'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: petClinicConfigSvcUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicConfigSvcUserManagedIdentity.properties.principalId, kvSecretPetClinicAppInsightsConnectionString.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.outputs.keyVaultName
    kvSecretName: kvSecretPetClinicAppInsightsConnectionString.outputs.kvSecretName
  }
}

module rbacKVSecretPetConfigSvcAppInsightsInstrKey './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-pet-config-app-insights-instr-key'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: petClinicConfigSvcUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicConfigSvcUserManagedIdentity.properties.principalId, kvSecretPetClinicAppInsightsInstrumentationKey.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.outputs.keyVaultName
    kvSecretName: kvSecretPetClinicAppInsightsInstrumentationKey.outputs.kvSecretName
  }
}

module rbacKVSecretPetCustsSvcDSUri './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-pet-custs-ds-url'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: petClinicCustsSvcUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicCustsSvcUserManagedIdentity.properties.principalId, kvSecretPetClinicAppSpringDSURL.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.outputs.keyVaultName
    kvSecretName: kvSecretPetClinicAppSpringDSURL.outputs.kvSecretName
  }
}

module rbacKVSecretPetCustsSvcDBUSer './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-pet-custs-svc-db-user'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: petClinicCustsSvcUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicCustsSvcUserManagedIdentity.properties.principalId, kvSecretPetClinicCustsSvcDbUserName.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.outputs.keyVaultName
    kvSecretName: kvSecretPetClinicCustsSvcDbUserName.outputs.kvSecretName
  }
}

module rbacKVSecretPetCustsSvcAppInsightsConStr './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-pet-custs-app-insights-con-str'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: petClinicCustsSvcUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicCustsSvcUserManagedIdentity.properties.principalId, kvSecretPetClinicAppInsightsConnectionString.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.outputs.keyVaultName
    kvSecretName: kvSecretPetClinicAppInsightsConnectionString.outputs.kvSecretName
  }
}

module rbacKVSecretPetCustsSvcAppInsightsInstrKey './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-pet-custs-app-insights-instr-key'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: petClinicCustsSvcUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicCustsSvcUserManagedIdentity.properties.principalId, kvSecretPetClinicAppInsightsInstrumentationKey.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.outputs.keyVaultName
    kvSecretName: kvSecretPetClinicAppInsightsInstrumentationKey.outputs.kvSecretName
  }
}

module rbacKVSecretPetVetsSvcDSUri './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-pet-vets-svc-ds-url'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: petClinicVetsSvcUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicVetsSvcUserManagedIdentity.properties.principalId, kvSecretPetClinicAppSpringDSURL.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.outputs.keyVaultName
    kvSecretName: kvSecretPetClinicAppSpringDSURL.outputs.kvSecretName
  }
}

module rbacKVSecretPetVetsSvcDBUSer './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-pet-vets-svc-db-user'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: petClinicVetsSvcUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicVetsSvcUserManagedIdentity.properties.principalId, kvSecretPetClinicVetsSvcDbUserName.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.outputs.keyVaultName
    kvSecretName: kvSecretPetClinicVetsSvcDbUserName.outputs.kvSecretName
  }
}

module rbacKVSecretPetVetsSvcAppInsightsConStr './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-pet-vets-app-insights-con-str'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: petClinicVetsSvcUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicVetsSvcUserManagedIdentity.properties.principalId, kvSecretPetClinicAppInsightsConnectionString.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.outputs.keyVaultName
    kvSecretName: kvSecretPetClinicAppInsightsConnectionString.outputs.kvSecretName
  }
}

module rbacKVSecretPetVetsSvcAppInsightsInstrKey './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-pet-vets-app-insights-instr-key'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: petClinicVetsSvcUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicVetsSvcUserManagedIdentity.properties.principalId, kvSecretPetClinicAppInsightsInstrumentationKey.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.outputs.keyVaultName
    kvSecretName: kvSecretPetClinicAppInsightsInstrumentationKey.outputs.kvSecretName
  }
}

module rbacKVSecretPetVisitsSvcDSUri './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-pet-visits-svc-ds-url'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: petClinicVisitsSvcUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicVisitsSvcUserManagedIdentity.properties.principalId, kvSecretPetClinicAppSpringDSURL.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.outputs.keyVaultName
    kvSecretName: kvSecretPetClinicAppSpringDSURL.outputs.kvSecretName
  }
}

module rbacKVSecretPetVisitsSvcDBUSer './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-pet-visits-svc-db-user'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: petClinicVisitsSvcUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicVisitsSvcUserManagedIdentity.properties.principalId, kvSecretPetClinicVisitsSvcDbUserName.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.outputs.keyVaultName
    kvSecretName: kvSecretPetClinicVisitsSvcDbUserName.outputs.kvSecretName
  }
}

module rbacKVSecretPetVisitsSvcAppInsightsConStr './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-pet-visits-app-insights-con-str'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: petClinicVisitsSvcUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicVisitsSvcUserManagedIdentity.properties.principalId, kvSecretPetClinicAppInsightsConnectionString.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.outputs.keyVaultName
    kvSecretName: kvSecretPetClinicAppInsightsConnectionString.outputs.kvSecretName
  }
}

module rbacKVSecretPetVisitsSvcAppInsightsInstrKey './components/role-assignment-kv-secret.bicep' = {
  name: 'rbac-kv-secret-pet-visits-app-insights-instr-key'
  params: {
    roleDefinitionId: keyVaultSecretsUser.id
    principalId: petClinicVisitsSvcUserManagedIdentity.properties.principalId
    roleAssignmentNameGuid: guid(petClinicVisitsSvcUserManagedIdentity.properties.principalId, kvSecretPetClinicAppInsightsInstrumentationKey.outputs.kvSecretId, keyVaultSecretsUser.id)
    kvName: keyVault.outputs.keyVaultName
    kvSecretName: kvSecretPetClinicAppInsightsInstrumentationKey.outputs.kvSecretName
  }
}

module dnsZone './components/dns-zone.bicep' = if (dnsZoneName != '') {
  name: 'child-dns-zone'
  params: {
    zoneName: dnsZoneName
    recordNames: [todoAppDnsRecordName, petClinicDnsRecordName, petClinicAdminDnsRecordName, petClinicGrafanaDnsRecordName, petClinicTracingServerDnsRecordName ]
    publicIPAddressName: '${appGatewayName}-ip'
    parentZoneName: parentDnsZoneName
    parentZoneRG: parentDnsZoneRGVar
    parentZoneSubscriptionId: parentDnsZoneSubscriptionIdVar
    parentZoneTagsArray: parentDnsZoneTagsArray
    tagsArray: aksTagsArray
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

@description('This is the built-in Contributor role. See https://learn.microsoft.com/en-gb/azure/role-based-access-control/built-in-roles#contributor')
resource contributor 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: resourceGroup()
  name: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
}

@description('This is the built-in Reader role. See https://learn.microsoft.com/en-gb/azure/role-based-access-control/built-in-roles#reader')
resource reader 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: resourceGroup()
  name: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
}

@description('This is the built-in Managed Identity Operator role. See https://learn.microsoft.com/en-gb/azure/role-based-access-control/built-in-roles#reader')
resource managedIdentityOperator 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: resourceGroup()
  name: 'f1a07417-d97a-45cb-824c-7a7467783830'
}

output todoAppUserManagedIdentityName string = todoAppUserManagedIdentity.name
output todoAppUserManagedIdentityPrincipalId string = todoAppUserManagedIdentity.properties.principalId
output todoAppUserManagedIdentityClientId string = todoAppUserManagedIdentity.properties.clientId
output todoAppDbUserName string = todoAppDbUserName

output petClinicAppUserManagedIdentityName string = petClinicAppUserManagedIdentity.name
output petClinicAppUserManagedIdentityPrincipalId string = petClinicAppUserManagedIdentity.properties.principalId
output petClinicAppUserManagedIdentityClientId string = petClinicAppUserManagedIdentity.properties.clientId

output petClinicConfigSvcUserManagedIdentityName string = petClinicConfigSvcUserManagedIdentity.name
output petClinicConfigSvcUserManagedIdentityPrincipalId string = petClinicConfigSvcUserManagedIdentity.properties.principalId
output petClinicConfigSvcUserManagedIdentityClientId string = petClinicConfigSvcUserManagedIdentity.properties.clientId

output petClinicCustsSvcUserManagedIdentityName string = petClinicCustsSvcUserManagedIdentity.name
output petClinicCustsSvcUserManagedIdentityPrincipalId string = petClinicCustsSvcUserManagedIdentity.properties.principalId
output petClinicCustsSvcUserManagedIdentityClientId string = petClinicCustsSvcUserManagedIdentity.properties.clientId
output petClinicCustsSvcDbUserName string = petClinicCustsSvcDbUserName

output petClinicVetsSvcUserManagedIdentityName string = petClinicVetsSvcUserManagedIdentity.name
output petClinicVetsSvcUserManagedIdentityPrincipalId string = petClinicVetsSvcUserManagedIdentity.properties.principalId
output petClinicVetsSvcUserManagedIdentityClientId string = petClinicVetsSvcUserManagedIdentity.properties.clientId
output petClinicVetsSvcDbUserName string = petClinicVetsSvcDbUserName

output petClinicVisitsSvcUserManagedIdentityName string = petClinicVisitsSvcUserManagedIdentity.name
output petClinicVisitsSvcUserManagedIdentityPrincipalId string = petClinicVisitsSvcUserManagedIdentity.properties.principalId
output petClinicVisitsSvcUserManagedIdentityClientId string = petClinicVisitsSvcUserManagedIdentity.properties.clientId
output petClinicVisitsSvcDbUserName string = petClinicVisitsSvcDbUserName

output appGatewayName string = appGateway.outputs.appGatewayName
output appGatewayIdentityName string = appGateway.outputs.appGatewayIdentityName
output appGatewayIdentityResourceId string = appGateway.outputs.appGatewayIdentityResourceId
output appGatewayIdentityPrincipalId string = appGateway.outputs.appGatewayIdentityPrincipalId
output appGatewayIdentityClientId string = appGateway.outputs.appGatewayIdentityClientId

output agicIdentityName string = aks.outputs.agicIdentityName
output agicIdentityPrincipalId string = aks.outputs.agicIdentityPrincipalId
output agicIdentityClientId string = aks.outputs.agicIdentityClientId
output agicIdentityResourceId string = aks.outputs.agicIdentityResourceId
