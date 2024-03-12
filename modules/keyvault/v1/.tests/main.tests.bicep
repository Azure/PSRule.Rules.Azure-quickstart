// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

@description('Configures the location to deploy the Azure resources.')
param location string = resourceGroup().location

// Test with only required parameters
module test_required_params '../main.bicep' = {
  name: 'test_required_params'
  params: {
    name: 'kvtest001'
    location: location
    tags: {
      env: 'test'
    }
  }
}

// Test with Log Analytics workspace configure for auditing
module test_with_audit_logs '../main.bicep' = {
  name: 'test_with_audit_logs'
  params: {
    name: 'kvtest002'
    location: location
    tags: {
      env: 'test'
    }
    workspaceId: '/subscriptions/<subscription_id>/resourceGroups/rg-test/providers/Microsoft.OperationalInsights/workspaces/latest001'
  }
}
