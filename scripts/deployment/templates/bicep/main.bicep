param acaName string

param acaTags string = '{ "CostCentre": "DEV", "Department": "RESEARCH", "WorkloadType": "TEST" }'

param pgsqlName string = '${replace(acaName,'_','-')}-pgsql'
param pgsqlAADAdminGroupName string
param pgsqlAADAdminGroupObjectId string
param pgsqlTodoAppDbName string
param pgsqlPetClinicDbName string
// param petClinicCustsSvcDbUserName string // = 'pet_clinic_custs_svc'
// param petClinicVetsSvcDbUserName string // = 'pet_clinic_vets_svc'
// param petClinicVisitsSvcDbUserName string // = 'pet_clinic_visits_svc'

param pgsqlSubscriptionId string = subscription().id
param pgsqlRG string = resourceGroup().name
param pgsqlTags string = acaTags

// param petClinicAppUserManagedIdentityName string = '${acaName}-pet-clinic-app-identity'
// param petClinicConfigSvcUserManagedIdentityName string = '${acaName}-pet-clinic-config-identity'
// param petClinicCustsSvcUserManagedIdentityName string = '${acaName}-pet-clinic-custs-identity'
// param petClinicVetsSvcUserManagedIdentityName string = '${acaName}-pet-clinic-vets-identity'
// param petClinicVisitsSvcUserManagedIdentityName string = '${acaName}-pet-clinic-visits-identity'

// @description('URI of the GitHub config repo, for example: https://github.com/spring-petclinic/spring-petclinic-microservices-config')
// param petClinicGitConfigRepoUri string
// @description('User name used to access the GitHub config repo')
// param petClinicGitConfigRepoUserName string
// @secure()
// @description('Password (PAT) used to access the GitHub config repo')
// param petClinicGitConfigRepoPassword string

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

// resource petClinicAppUserManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
//   name: petClinicAppUserManagedIdentityName
//   location: location
//   tags: acaTagsArray
// }

// resource petClinicConfigSvcUserManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
//   name: petClinicConfigSvcUserManagedIdentityName
//   location: location
//   tags: acaTagsArray
// }

// resource petClinicCustsSvcUserManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
//   name: petClinicCustsSvcUserManagedIdentityName
//   location: location
//   tags: acaTagsArray
// }

// resource petClinicVetsSvcUserManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
//   name: petClinicVetsSvcUserManagedIdentityName
//   location: location
//   tags: acaTagsArray
// }

// resource petClinicVisitsSvcUserManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
//   name: petClinicVisitsSvcUserManagedIdentityName
//   location: location
//   tags: acaTagsArray
// }

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

// module kvSecretPetClinicConfigRepoURI 'components/kv-secret.bicep' = {
//   name: 'kv-secret-pet-clinic-config-repo-uri'
//   params: {
//     keyVaultName: keyVault.outputs.keyVaultName
//     secretName: 'PET-CLINIC-CONFIG-SVC-GIT-REPO-URI'
//     secretValue: petClinicGitConfigRepoUri
//   }
// }

// module kvSecretPetClinicConfigRepoUserName 'components/kv-secret.bicep' = {
//   name: 'kv-secret-pet-clinic-config-repo-usern-ame'
//   params: {
//     keyVaultName: keyVault.outputs.keyVaultName
//     secretName: 'PET-CLINIC-CONFIG-SVC-GIT-REPO-USERNAME'
//     secretValue: petClinicGitConfigRepoUserName
//   }
// }

// module kvSecretPetClinicConfigRepoPassword 'components/kv-secret.bicep' = {
//   name: 'kv-secret-pet-clinic-config-repo-password'
//   params: {
//     keyVaultName: keyVault.outputs.keyVaultName
//     secretName: 'PET-CLINIC-CONFIG-SVC-GIT-REPO-PASSWORD'
//     secretValue: petClinicGitConfigRepoPassword
//   }
// }

// module kvSecretPetClinicAppSpringDSURL 'components/kv-secret.bicep' = {
//   name: 'kv-secret-pet-clinic-app-ds-url'
//   params: {
//     keyVaultName: keyVault.outputs.keyVaultName
//     secretName: 'PET-CLINIC-APP-SPRING-DATASOURCE-URL'
//     secretValue: 'jdbc:postgresql://${pgsqlName}.postgres.database.azure.com:5432/${pgsqlPetClinicDbName}'
//   }
// }

// module kvSecretPetClinicCustsSvcDbUserName 'components/kv-secret.bicep' = {
//   name: 'kv-secret-pet-clinic-custs-svc-ds-username'
//   params: {
//     keyVaultName: keyVault.outputs.keyVaultName
//     secretName: 'PET-CLINIC-CUSTS-SVC-SPRING-DS-USER'
//     secretValue: petClinicCustsSvcDbUserName
//   }
// }

// module kvSecretPetClinicVetsSvcDbUserName 'components/kv-secret.bicep' = {
//   name: 'kv-secret-pet-clinic-vets-svc-ds-username'
//   params: {
//     keyVaultName: keyVault.outputs.keyVaultName
//     secretName: 'PET-CLINIC-VETS-SVC-SPRING-DS-USER'
//     secretValue: petClinicVetsSvcDbUserName
//   }
// }

// module kvSecretPetClinicVisitsSvcDbUserName 'components/kv-secret.bicep' = {
//   name: 'kv-secret-pet-clinic-visits-svc-ds-username'
//   params: {
//     keyVaultName: keyVault.outputs.keyVaultName
//     secretName: 'PET-CLINIC-VISITS-SVC-SPRING-DS-USER'
//     secretValue: petClinicVisitsSvcDbUserName
//   }
// }

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
