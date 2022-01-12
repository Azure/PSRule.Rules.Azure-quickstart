// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Note:
// This Azure Bicep code demonistrates a deployment of one or more modules.
// This file has multiple template errors to show validation.

// An example Storage Account
module storage '../../../../../modules/storage/v1/main.bicep' = {
  name: 'storage-deployment'
  params: {
    name: 'stbicepapp002'

    location: 'antartic'

    // Don't allow anonymous access types of blob or container
    allowBlobPublicAccess: false
  }
}

// An example Key Vault
module keyvault '../../../../../modules/keyvault/v1/main.bicep' = {
  name: 'keyvault-deployment'
  params: {
    name: 'kv-bicep-app-002'

    // An env tag must be test, dev, or prod
    tags: {
      env: 'demo'
    }
  }
}
