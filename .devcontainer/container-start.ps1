# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# Note:
# This is run during container startup.

# Update modules
Update-Module PSRule.Rules.Azure -Scope CurrentUser -Force;

# Fetch the latest Bicep CLI binary
curl -Lo bicep https://github.com/Azure/bicep/releases/latest/download/bicep-linux-x64
# Mark it as executable
chmod +x ./bicep
# Add bicep to your PATH (requires admin)
sudo mv ./bicep /usr/local/bin/bicep
# Verify you can now access the 'bicep' command
bicep --version
# Done!
