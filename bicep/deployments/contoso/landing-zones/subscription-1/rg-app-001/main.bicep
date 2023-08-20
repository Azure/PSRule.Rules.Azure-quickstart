targetScope = 'resourceGroup'

param name string
param location string = resourceGroup().location

@allowed([
  'Allow'
  'Deny'
])
param defaultAction string = 'Deny'
param environment string
param workspaceId string = ''

resource vault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: name
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenant().tenantId
    enableSoftDelete: true
    enablePurgeProtection: true
    enableRbacAuthorization: true
    networkAcls: {
      defaultAction: defaultAction
    }
  }
  tags: {
    env: environment
  }
}

@sys.description('Configure auditing for Key Vault.')
resource logs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(workspaceId)) {
  name: 'service'
  scope: vault
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
      }
    ]
  }
}
