# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# Note:
# This script demonstrates using PowerShell-based rules.

# Synopsis: Policy exemptions must be approved by the security team and stored within deployments/contoso/landing-zones/subscription-1/policy/.
Rule 'Org.CodeOwners' -Type 'Microsoft.Authorization/policyExemptions' {
    $Assert.WithinPath($PSRule.Source['Parameter'], 'File', @(
        'template/deployments/contoso/landing-zones/subscription-1/policy/'
    ));
}
