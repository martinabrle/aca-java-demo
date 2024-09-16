param miName string
param roleAssignmentNameGuid string
param roleDefinitionId string
param principalId string

resource appGwIdentity 'Microsoft.ManagedIdentity/identities@2023-01-31' existing = {
  name: miName
}
resource appGwRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: roleAssignmentNameGuid
  scope: appGwIdentity
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}
