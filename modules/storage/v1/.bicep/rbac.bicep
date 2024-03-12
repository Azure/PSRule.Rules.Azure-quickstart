// Configure role assignments for the Storage Account

// ----------
// PARAMETERS
// ----------

@sys.description('The display name of the role to assign or the GUID.')
param role string

@sys.description('The GUID of the identity object to assign.')
param principalId string

@sys.description('A description of the assignment.')
param description string = ''

@allowed([
  'ServicePrincipal'
  'Group'
  'User'
  'ForeignGroup'
  'Device'
])
@sys.description('The principal type to assign.')
param principalType string = 'ServicePrincipal'

@sys.description('The name of the Storage Account.')
param resourceName string

// ---------
// VARIABLES
// ---------

var roles = {
  Owner: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
  Contributor: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
  Reader: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
  'User Access Administrator': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '18d7d88d-d35e-4fb5-a5c3-7773c20a72d9')
  'Storage Account Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '17d1049b-9a84-46fb-8f53-869881c3d3ab')
  'Storage Account Key Operator Service Role': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '81a9662b-bebf-436f-a333-f67b29880f12')
  'Storage Blob Data Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
  'Storage Blob Data Owner': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b')
  'Storage Blob Data Reader': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1')
  'Storage File Data SMB Share Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '0c867c2a-1d8c-454a-a3db-ab2ea1bdc8bb')
  'Storage File Data SMB Share Elevated Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'a7264617-510b-434b-a828-9731dc254ea7')
  'Storage File Data SMB Share Reader': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'aba4ae5f-2193-4029-9191-0cb91df5e314')
}
var roleDefinitionId = contains(roles, role) ? roles[role] : subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role)

// ---------
// RESOURCES
// ---------

resource r 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: resourceName
}

@sys.description('Assign permissions to an Azure AD principal.')
resource rbac 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(r.id, principalId, roleDefinitionId)
  scope: r
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinitionId
    principalType: principalType
    description: description
  }
}
