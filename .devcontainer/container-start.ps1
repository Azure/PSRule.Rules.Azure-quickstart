# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# Note:
# This is run during container startup.

# Update modules
Update-Module PSRule.Rules.Azure -Scope CurrentUser -Force;
Update-Module PSRule -Scope CurrentUser -Force;

# Update Bicep
az bicep upgrade
