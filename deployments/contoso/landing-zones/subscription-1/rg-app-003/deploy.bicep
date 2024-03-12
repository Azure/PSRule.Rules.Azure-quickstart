// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Note:
// This Azure Bicep code demonstrates using an AVM module.

module vault 'br/public:avm/res/key-vault/vault:0.3.5' = {
  // The name of the deployment.
  name: '${uniqueString(deployment().name)}-test-kvvwaf'
  params: {

    // The name of the key vault.
    name: 'kvvwaf002'

    // Try setting any of these to false to flag an issue.
    enablePurgeProtection: true
    enableRbacAuthorization: true

    networkAcls: {
      bypass: 'AzureServices'

      // Try setting the firewall to 'Allow' traffic by default to flag an issue.
      defaultAction: 'Deny'
    }

    diagnosticSettings: [
      {
        workspaceResourceId: '<workspaceResourceId>'
      }
    ]

    softDeleteRetentionInDays: 7

    // An env tag must be test, dev, or prod.
    // Try setting this to 'demo' to fail the custom organization Org.Azure.Tags rule.
    // See .ps-rule/Org.Rule.yaml for details.
    tags: {
      env: 'dev'
    }
  }
}
