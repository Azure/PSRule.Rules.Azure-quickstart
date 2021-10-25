// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Note:
// This Azure Bicep code demonistrates a deployment of one or more modules.
// This file has multiple template errors to show validation.

// An example Storage Account
module storage '../../../../../templates/storage/v2/template.bicep' = {
  name: 'storage-deployment'
  params: {
    storageAccountName: 'st002'

    // Don't allow anonymous access types of blob or container
    allowBlobPublicAccess: false
  }
}

// An example Key Vault
module keyvault '../../../../../templates/keyvault/v2/template.json' = {
  name: 'keyvault-deployment'
  params: {

    // An env tag must be test, dev, or prod
    tags: {
      env: 'demo'
    }
    vaultName: 'vault002'
  }
}
