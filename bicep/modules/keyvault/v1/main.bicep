// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

metadata name = 'Key Vault'
metadata description = 'Create or update an Azure Key Vault.'

@sys.description('The name of the Key Vault.')
param name string

@sys.description('The Azure region to deploy to.')
@metadata({
  strongType: 'location'
})
param location string = resourceGroup().location

@sys.description('The access policies defined for this vault.')
@metadata({
  example: [
    {
      objectId: '<object_id>'
      tenantId: '<tenant_id>'
      permissions: {
        secrets: [
          'Get'
          'List'
          'Set'
        ]
      }
    }
  ]
})
param accessPolicies array = []

@sys.description('Determines if Azure can deploy certificates from this Key Vault.')
param useDeployment bool = true

@sys.description('Determines if templates can reference secrets from this Key Vault.')
param useTemplate bool = true

@sys.description('Determines if this Key Vault can be used for Azure Disk Encryption.')
param useDiskEncryption bool = true

@sys.description('Determine if soft delete is enabled on this Key Vault.')
param useSoftDelete bool = true

@sys.description('Determine if purge protection is enabled on this Key Vault.')
param usePurgeProtection bool = true

@sys.description('The number of days to retain soft deleted vaults and vault objects.')
@minValue(7)
@maxValue(90)
param softDeleteDays int = 90

@sys.description('Determines if access to the objects granted using RBAC. When true, access policies are ignored.')
param useRBAC bool = false

@sys.description('The network firewall defined for this vault.')
param networkAcls object = {
  defaultAction: 'Allow'
  bypass: 'AzureServices'
  ipRules: []
  virtualNetworkRules: []
}

@sys.description('The workspace to store audit logs.')
@metadata({
  strongType: 'Microsoft.OperationalInsights/workspaces'
  example: '/subscriptions/<subscription_id>/resourceGroups/<resource_group>/providers/Microsoft.OperationalInsights/workspaces/<workspace_name>'
})
param workspaceId string = ''

@sys.description('Tags to apply to the resource.')
@metadata({
  example: {
    service: '<service_name>'
    env: 'prod'
  }
})
param tags object = resourceGroup().tags

// Define a Key Vault
resource vault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: name
  location: location
  properties: {
    enabledForDeployment: useDeployment
    enabledForTemplateDeployment: useTemplate
    enabledForDiskEncryption: useDiskEncryption
    accessPolicies: accessPolicies
    tenantId: subscription().tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
    networkAcls: networkAcls
    enableSoftDelete: useSoftDelete
    enablePurgeProtection: usePurgeProtection
    softDeleteRetentionInDays: softDeleteDays
    enableRbacAuthorization: useRBAC
  }
  tags: tags
}

// Configure logging
resource vaultName_Microsoft_Insights_service 'Microsoft.KeyVault/vaults/providers/diagnosticSettings@2016-09-01' = if (!empty(workspaceId)) {
  name: '${name}/Microsoft.Insights/service'
  location: location
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
      }
    ]
  }
  dependsOn: [
    vault
  ]
}

output resourceId string = vault.id
