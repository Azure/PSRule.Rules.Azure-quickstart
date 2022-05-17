// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Note:
// This Azure Bicep code demonistrates a deployment of one or more modules.
// This file has multiple template errors to show validation.

@description('Configures the location to deploy the Azure resources.')
param location string = resourceGroup().location

// An example Storage Account
module storage '../../../../../modules/storage/v1/main.bicep' = {
  name: 'storage-deployment'
  params: {
    name: 'stbicepapp002'

    // The Azure location must be valid
    // Try setting this to 'Antarctica'
    location: location

    // Don't allow anonymous access types of blob or container.
    // Try setting this false to fail the Azure.Storage.BlobPublicAccess rule.
    allowBlobPublicAccess: false

    // An env tag must be test, dev, or prod.
    // Try setting this to 'demo' to fail the Org.Azure.Tags rule.
    tags: {
      env: 'dev'
    }
  }
}

// An example Key Vault
module keyvault '../../../../../modules/keyvault/v1/main.bicep' = {
  name: 'keyvault-deployment'
  params: {
    name: 'kv-bicep-app-002'
    location: location

    // Must have a workspace
    // Try commenting out this line to have the Azure.KeyVault.Logs rule fail.
    workspaceId: '/subscriptions/<subscription_id>/resourceGroups/rg-test/providers/Microsoft.OperationalInsights/workspaces/latest001'

    // An env tag must be test, dev, or prod.
    // Try setting this to 'demo' to fail the Org.Azure.Tags rule.
    tags: {
      env: 'dev'
    }
  }
}
