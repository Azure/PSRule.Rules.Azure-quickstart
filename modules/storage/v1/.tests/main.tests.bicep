// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

@description('Configures the location to deploy the Azure resources.')
param location string = resourceGroup().location

// Test with only required parameters
module test_required_params '../main.bicep' = {
  name: 'test_required_params'
  params: {
    name: 'sttest001'
    location: location
    tags: {
      env: 'test'
    }
  }
}

// Test blob storage with a private endpoint
module test_blob_private_endpoint '../main.bicep' = {
  name: 'test_blob_private_endpoint'
  params: {
    name: 'sttest002'
    location: location
    subnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', 'vnet-test', 'snet-test')
    tags: {
      env: 'test'
    }
  }
}

// Test file storage with a private endpoint
module test_file_private_endpoint '../main.bicep' = {
  name: 'test_file_private_endpoint'
  params: {
    name: 'sttest003'
    location: location
    storageKind: 'FileStorage'
    sku: 'Premium_LRS'
    subnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', 'vnet-test', 'snet-test')
    tags: {
      env: 'test'
    }
  }
}
