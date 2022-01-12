// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Test with only required parameters
module test_required_params '../main.bicep' = {
  name: 'test_required_params'
  params: {
    name: 'sttest001'
  }
}
