param acaName string
param acaTags string

param appVersion string

param todoAppUserManagedIdentityName string = '${acaName}-todo-app-identity'
param appName string = 'todo-app'
param containerImage string

param certificateId string = ''

param containerRegistryName string = replace(replace(acaName,'_', ''),'-','')
param containerRegistrySubscriptionId string = subscription().id
param containerRegistryRG string = resourceGroup().name

param dnsZoneName string = ''
param parentDnsZoneName string = ''

var containerRegistrySubscriptionIdVar = (containerRegistrySubscriptionId == '')
  ? subscription().id
  : containerRegistrySubscriptionId
var containerRegistryRGVar = (containerRegistryRG == '') ? resourceGroup().name : containerRegistryRG

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

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' existing = {
  name: containerRegistryName
  scope: resourceGroup(containerRegistrySubscriptionIdVar, containerRegistryRGVar)
}

resource acaEnvironment 'Microsoft.App/managedEnvironments@2024-03-01' existing = {
  name: acaName
}

resource acaApp 'Microsoft.App/containerApps@2024-03-01' = {
   name: appName
   tags: json(acaTags)
   identity: {
      type: 'UserAssigned'
      userAssignedIdentities: {
         '${todoAppUserManagedIdentity.id}': {}
      }
   }
   properties: {
      environmentId: acaEnvironment.id
      configuration: {
          activeRevisionsMode: 'Multiple'
          secrets: [
            {
              name:  toLower(kvSecretTodoAppSpringDSURI.name)
              keyVaultUrl: kvSecretTodoAppSpringDSURI.properties.secretUri
              identity: todoAppUserManagedIdentity.id
            }
            {
              name:  toLower(kvSecretTodoAppDbUserName.name)
              keyVaultUrl: kvSecretTodoAppDbUserName.properties.secretUri
              identity: todoAppUserManagedIdentity.id
            }
            {
              name:  toLower(kvSecretTodoAppInsightsConnectionString.name)
              keyVaultUrl: kvSecretTodoAppInsightsConnectionString.properties.secretUri
              identity: todoAppUserManagedIdentity.id
            }
            {
              name:  toLower(kvSecretTodoAppInsightsInstrumentationKey.name)
              keyVaultUrl: kvSecretTodoAppInsightsInstrumentationKey.properties.secretUri
              identity: todoAppUserManagedIdentity.id
            }
          ]
          registries: [
            {
              server: '${containerRegistry.name}.azurecr.io'
              identity: todoAppUserManagedIdentity.id
            }
          ]
          ingress: {
            targetPort: 80
            external: true
            clientCertificateMode: 'ignore'
            customDomains: empty(certificateId) ? [
              {
                name: '${appName}.${dnsZoneName}.${parentDnsZoneName}'
                bindingType: 'Disabled'
              }
            ] : [
              {
                name: '${appName}.${dnsZoneName}.${parentDnsZoneName}'
                certificateId: certificateId
                bindingType:'SniEnabled'
              }
            ]
          }
      }
      template: {
        revisionSuffix: replace(appVersion,'.','-')
        containers: [
            {
              image: containerImage
              name: appName
              env: [
                {
                  name: replace(kvSecretTodoAppSpringDSURI.name,'-','_')
                  secretRef: toLower(kvSecretTodoAppSpringDSURI.name)
                }
                {
                  name: replace(kvSecretTodoAppDbUserName.name,'-','_')
                  secretRef: toLower(kvSecretTodoAppDbUserName.name)
                }
                {
                  name: replace(kvSecretTodoAppInsightsConnectionString.name,'-','_')
                  secretRef: toLower(kvSecretTodoAppInsightsConnectionString.name)
                }
                {
                  name: replace(kvSecretTodoAppInsightsInstrumentationKey.name,'-','_')
                  secretRef: toLower(kvSecretTodoAppInsightsInstrumentationKey.name)
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

module dnsRecordTXT './components/dns-record-txt.bicep' = {
  name: 'dns-record-txt'
  params: {
    dnsZoneName: '${dnsZoneName}.${parentDnsZoneName}'
    dnsRecordName: 'asuid.${appName}'
    dnsRecordValue: acaApp.properties.customDomainVerificationId
  }
}

module dnsRecordCname './components/dns-record-cname.bicep' = {
  name: 'dns-record-cname'
  params: {
    dnsZoneName: '${dnsZoneName}.${parentDnsZoneName}'
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
  tags: json(acaTags)
  properties: {
    domainControlValidation: 'CNAME'
    subjectName: '${appName}.${dnsZoneName}.${parentDnsZoneName}'
  }
  location: location
}
