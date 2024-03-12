// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Note:
// This Azure Bicep parameter file demonstrates using parameters.

using 'main.bicep'

// The env tag must be test, dev, or prod.
// Try setting this to 'demo' to fail the custom organization Org.Azure.Tags rule.
// See .ps-rule/Org.Rule.yaml for details.
param environment = 'dev'

param name = 'kv-example-001'

// Key Vault should only accept explicitly allowed traffic through the firewall.
// Set to 'Allow' to fail Azure.KeyVault.Firewall.
param defaultAction = 'Deny'

param workspaceId = '/subscriptions/00000000-0000-0000-0000-000000000000/resourcegroups/rg-test/providers/microsoft.operationalinsights/workspaces/workspace-001'
