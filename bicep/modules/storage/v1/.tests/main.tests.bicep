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
