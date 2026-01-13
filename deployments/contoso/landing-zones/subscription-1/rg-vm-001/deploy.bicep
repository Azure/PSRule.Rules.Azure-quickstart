// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Note:
// This Azure Bicep code demonstrates a deployment of a VM that uses a password with two common
// deployment options. 1. Using a password from the pipeline. 2. Using a password from a Key Vault secret.

// ---------------------------------------------------------------
// OPTION 1: A VM deployment using the password from the pipeline.
// ---------------------------------------------------------------

// If your pipeline passes a password in as a parameter to the deployment script, use this option.
// For expansion with PSRule, a dummy value for `adminPassword` is used set in `ps-rule.yaml` with
// the `AZURE_PARAMETER_DEFAULTS` configuration option. This allows PSRule to expand the deployment,
// without exposing your secret in the code or PSRule.

@secure()
@description('Load the admin password from the pipeline.')
param adminPassword string

@description('A VM deployment using a password from the pipeline.')
module vm001 '../../../../../modules/virtual-machine-windows/v1/main.bicep' = {
  params: {
    name: 'vm-001'
    adminPassword: adminPassword
    adminUsername: 'vm-admin'
    imageSKU: '2022-Datacenter'
    size: 'Standard_D4ds_v4'
    subnetId: vnet.id
    tags: {
      env: 'dev'
    }
  }
}

// ---------------------------------------------------------------------
// OPTION 2: A VM deployment using the password from a Key Vault secret.
// ---------------------------------------------------------------------

// If your VM deployment is able to use a Key Vault secret that is already deployed to Azure, use this option.
// When you reference a Key Vault secret, PSRule will automatically substitute a placeholder for the secret value
// during expansion. So you can use the secret in your deployment without exposing it as a deployment parameter.

// NB: PSRule never actually attempts to retrieve the secret value, so it does not need access to the secret.

@description('An existing Key Vault to use for the VM deployment.')
resource vault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: 'kv-001'
}

@description('Load the admin password from a Key Vault secret.')
module vm002 '../../../../../modules/virtual-machine-windows/v1/main.bicep' = {
  params: {
    name: 'vm-002'
    adminPassword: vault.getSecret('vm002-admin-password')
    adminUsername: 'vm-admin'
    imageSKU: '2022-Datacenter'
    size: 'Standard_D4ds_v4'
    subnetId: vnet.id
    tags: {
      env: 'dev'
    }
  }
}

// ---------------
// Other resources
// ---------------

// An existing virtual network and subnet to connect the VM.
resource vnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = {
  name: 'vnet-001/subnet-001'
}
