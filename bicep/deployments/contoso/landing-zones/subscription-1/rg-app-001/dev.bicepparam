using 'main.bicep'

param environment = 'dev'
param name = 'kv-example-001'

// Key Vault should only accept explicitly allowed traffic through the firewall.
// Set to 'Allow' to fail Azure.KeyVault.Firewall.
param defaultAction = 'Deny'

param workspaceId = '/subscriptions/00000000-0000-0000-0000-000000000000/resourcegroups/rg-test/providers/microsoft.operationalinsights/workspaces/workspace-001'
