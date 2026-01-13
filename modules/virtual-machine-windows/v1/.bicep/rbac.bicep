// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Configure role assignments for the Virtual Machine

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

@sys.description('The name of the Virtual Machine name.')
param resource string

// ---------
// VARIABLES
// ---------

// Map of common RBAC role names to their IDs.
// Azure uses specific GUIDs for built-in roles however it is easier to reference them by name.
var roles = {
  Owner: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
  Contributor: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
  Reader: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
  'User Access Administrator': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '18d7d88d-d35e-4fb5-a5c3-7773c20a72d9'
  )
  'Virtual Machine Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '9980e02c-c2be-4d73-94e8-173b1dc7cf3c'
  )
}

var roleDefinitionId = roles[?role] ?? subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role)

// ---------
// RESOURCES
// ---------

resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' existing = {
  name: resource
}

@sys.description('Assign permissions to an Azure AD principal.')
resource rbac 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(vm.id, principalId, roleDefinitionId)
  scope: vm
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinitionId
    principalType: principalType
    description: description
  }
}
