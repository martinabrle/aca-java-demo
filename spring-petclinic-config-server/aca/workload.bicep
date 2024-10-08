param acaName string
param acaTags string = '{ "CostCentre": "DEV", "Department": "RESEARCH", "WorkloadType": "TEST" }'

param appVersion string

param petClinicConfigSvcUserManagedIdentityName string = '${acaName}-pet-clinic-config-identity'
param appName string = 'config-server'
param appClientId string
param containerImage string

param certificateId string = ''

param containerRegistryName string = replace(replace(acaName,'_', ''),'-','')
param containerRegistrySubscriptionId string = subscription().id
param containerRegistryRG string = resourceGroup().name

param dnsZoneName string = ''
param petClinicDnsZoneName string = ''
param parentDnsZoneName string = ''

var acaTagsArray = json(empty(acaTags) ? '{ "CostCentre": "DEV", "Department": "RESEARCH", "WorkloadType": "TEST" }' : acaTags)

var containerRegistrySubscriptionIdVar = (containerRegistrySubscriptionId == '')
  ? subscription().id
  : containerRegistrySubscriptionId
var containerRegistryRGVar = (containerRegistryRG == '') ? resourceGroup().name : containerRegistryRG

param location string

resource petClinicConfigSvcUserManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: petClinicConfigSvcUserManagedIdentityName
}

resource kvSecretPetClinicAppInsightsConnectionString 'Microsoft.KeyVault/vaults/secrets@2024-04-01-preview' existing = {
  parent: keyVault
  name: 'PET-CLINIC-APP-INSIGHTS-CONNECTION-STRING'
}

resource kvSecretPetClinicAppInsightsInstrumentationKey 'Microsoft.KeyVault/vaults/secrets@2024-04-01-preview' existing = {
  parent: keyVault
  name: 'PET-CLINIC-APP-INSIGHTS-INSTRUMENTATION-KEY'
}

resource kvSecretPetClinicConfigRepoURI 'Microsoft.KeyVault/vaults/secrets@2024-04-01-preview' existing = {
  parent: keyVault
  name: 'PET-CLINIC-CONFIG-SVC-GIT-REPO-URI'
}

resource kvSecretPetClinicConfigRepoUserName 'Microsoft.KeyVault/vaults/secrets@2024-04-01-preview' existing = {
  parent: keyVault
  name: 'PET-CLINIC-CONFIG-SVC-GIT-REPO-USER'
}

resource kvSecretPetClinicConfigRepoPassword 'Microsoft.KeyVault/vaults/secrets@2024-04-01-preview' existing = {
  parent: keyVault
  name: 'PET-CLINIC-CONFIG-SVC-GIT-REPO-PWD'
}

resource keyVault 'Microsoft.KeyVault/vaults@2024-04-01-preview' existing = {
  name: '${acaName}-kv'
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' existing = {
  name: containerRegistryName
  scope: resourceGroup(containerRegistrySubscriptionIdVar, containerRegistryRGVar)
}

resource acaEnvironment 'Microsoft.App/managedEnvironments@2024-03-01' existing = {
  name: acaName
}

module dnsRecordTXT './components/dns-record-txt.bicep' = {
  name: 'dns-record-txt'
  params: {
    dnsZoneName: '${petClinicDnsZoneName}.${dnsZoneName}.${parentDnsZoneName}'
    dnsRecordName: 'asuid.${appName}'
    dnsRecordValue: acaEnvironment.properties.customDomainConfiguration.customDomainVerificationId
  }
}

resource acaApp 'Microsoft.App/containerApps@2024-03-01' = {
   name: appName
   tags: acaTagsArray
   dependsOn: [
    dnsRecordTXT
   ]
   identity: {
      type: 'UserAssigned'
      userAssignedIdentities: {
         '${petClinicConfigSvcUserManagedIdentity.id}': {}
      }
   }
   properties: {
      environmentId: acaEnvironment.id
      configuration: {
          activeRevisionsMode: 'Multiple'
          secrets: [
            {
              name: toLower(kvSecretPetClinicAppInsightsConnectionString.name)
              keyVaultUrl: kvSecretPetClinicAppInsightsConnectionString.properties.secretUri
              identity: petClinicConfigSvcUserManagedIdentity.id
            }
            {
              name: toLower(kvSecretPetClinicAppInsightsInstrumentationKey.name)
              keyVaultUrl: kvSecretPetClinicAppInsightsInstrumentationKey.properties.secretUri
              identity: petClinicConfigSvcUserManagedIdentity.id
            }
            {
              name: toLower(kvSecretPetClinicConfigRepoURI.name)
              keyVaultUrl: kvSecretPetClinicConfigRepoURI.properties.secretUri
              identity: petClinicConfigSvcUserManagedIdentity.id
            }
            {
              name: toLower(kvSecretPetClinicConfigRepoUserName.name)
              keyVaultUrl: kvSecretPetClinicConfigRepoUserName.properties.secretUri
              identity: petClinicConfigSvcUserManagedIdentity.id
            }
            {
              name: toLower(kvSecretPetClinicConfigRepoPassword.name)
              keyVaultUrl: kvSecretPetClinicConfigRepoURI.properties.secretUri //kvSecretPetClinicConfigRepoPassword.properties.secretUri
              identity: petClinicConfigSvcUserManagedIdentity.id
            }
          ]
          registries: [
            {
              server: '${containerRegistry.name}.azurecr.io'
              identity: petClinicConfigSvcUserManagedIdentity.id
            }
          ]
          ingress: {
            targetPort: 8888
            external: true
            clientCertificateMode: 'ignore'
            customDomains: empty(certificateId) ? [
              {
                name: '${appName}.${petClinicDnsZoneName}.${dnsZoneName}.${parentDnsZoneName}'
                bindingType: 'Disabled'
              }
            ] : [
              {
                name: '${appName}.${petClinicDnsZoneName}.${dnsZoneName}.${parentDnsZoneName}'
                certificateId: certificateId
                bindingType:'SniEnabled'
              }
            ]
          }
      }
      template: {
        revisionSuffix: replace(appVersion,'.','-')
        scale: {
          minReplicas: 1
          maxReplicas: 10
          rules: [
            {
              name: 'http-rule'
              http: {
                metadata: {
                  concurrentRequests: '100'
                }
              }
            }
          ]
        }
        containers: [
            {
              image: containerImage
              name: appName
              env: [
                {
                  name: 'CONFIG_SERVER_URL'
                  value: 'http://config-server:8888'
                }
                {
                  name: 'PORT'
                  value: '8888'
                }
                {
                  name: 'ENVIRONMENT'
                  value: 'ACA'
                }
                {
                  name: 'SPRING_DATASOURCE_SHOW_SQL'
                  value: 'true'
                }
                {
                  name: 'LOAD_DEMO_DATA'
                  value: 'true'
                }
                {
                  name: 'AZURE_TENANT_ID'
                  value: tenant().tenantId
                }
                {
                  name: 'AZURE_CLIENT_ID'
                  value: appClientId
                }
                {
                  name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
                  secretRef: toLower(kvSecretPetClinicAppInsightsConnectionString.name)
                }
                {
                  name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
                  secretRef: toLower(kvSecretPetClinicAppInsightsInstrumentationKey.name)
                }
                {
                  name:  'APPLICATIONINSIGHTS_CONFIGURATION_CONTENT'
                  value: '{ "role": { "name": "config-server" } }'
                }
                {
                  name: 'GIT_CONFIG_REPO_URI'
                  secretRef: toLower(kvSecretPetClinicConfigRepoURI.name)
                }
                {
                  name: 'GIT_USERNAME'
                  secretRef: toLower(kvSecretPetClinicConfigRepoUserName.name)
                }
                {
                  name: 'GIT_PASSWORD'
                  secretRef: toLower(kvSecretPetClinicConfigRepoPassword.name)
                }
              ]
              resources: {
                 cpu: json('0.5')
                 memory: '1.0Gi'
              }
            }
        ]
      }
    }
    location: location
}

module dnsRecordCname './components/dns-record-cname.bicep' = {
  name: 'dns-record-cname'
  params: {
    dnsZoneName: '${petClinicDnsZoneName}.${dnsZoneName}.${parentDnsZoneName}'
    dnsRecordName: appName
    dnsRecordValue: acaApp.properties.configuration.ingress.fqdn
  }
}

resource acaManagedCertificate 'Microsoft.App/managedEnvironments/managedCertificates@2024-03-01' = {
  parent: acaEnvironment
  name: 'managed-certificate-${appName}'
  dependsOn: [
    dnsRecordCname
    dnsRecordTXT
  ]
  tags: acaTagsArray
  properties: {
    domainControlValidation: 'CNAME'
    subjectName: '${appName}.${petClinicDnsZoneName}.${dnsZoneName}.${parentDnsZoneName}'
  }
  location: location
}
