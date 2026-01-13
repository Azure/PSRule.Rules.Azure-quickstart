// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Test Windows Virtual Machine module
targetScope = 'resourceGroup'

// ----------
// REFERENCES
// ----------

resource kv 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
  name: 'kv-001'
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' existing = {
  name: 'vnet-001'
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' existing = {
  parent: vnet
  name: 'subnet-001'
}

// ---------
// RESOURCES
// ---------

// Test a basic VM
module test_vm_with_no_disks '../main.bicep' = {
  name: 'test_vm_with_no_disks'
  params: {
    name: 'vm001'
    adminUsername: kv.getSecret('vm-username')
    adminPassword: kv.getSecret('vm-password')
    subnetId: subnet.id
    size: 'Standard_D2s_v3'
    imageSKU: '2022-Datacenter-Core'
    tags: {
      env: 'dev'
    }
  }
}

// Test a VM with two data disks
module test_vm_with_data_disks '../main.bicep' = {
  name: 'test_vm_with_data_disks'
  params: {
    name: 'vm002'
    adminUsername: kv.getSecret('vm-username')
    adminPassword: kv.getSecret('vm-password')
    subnetId: subnet.id
    size: 'Standard_D2s_v3'
    imageSKU: '2022-Datacenter-Core'
    dataDisks: [
      {
        diskSizeGB: 32
        sku: 'Standard_LRS'
      }
      {
        diskSizeGB: 64
        sku: 'Standard_LRS'
        caching: 'None'
      }
    ]
    tags: {
      env: 'dev'
    }
  }
}
