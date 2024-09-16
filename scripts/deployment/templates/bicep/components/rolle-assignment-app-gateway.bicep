param appGatewayName string
param roleAssignmentNameGuid string
param roleDefinitionId string
param principalId string

resource appGateway 'Microsoft.Network/applicationGateways@2023-05-01' existing = {
  name: appGatewayName
}

resource appGwRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: roleAssignmentNameGuid
  scope: appGateway
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}
