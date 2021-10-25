# Policy Exemption

Create or update an Azure Policy exemption for a Resource Group.

## Parameters

Parameter name | Required | Description
-------------- | -------- | -----------
exemptionNameSuffix | Yes      | This value will be added as a suffix to the exemption name.
assignmentId   | Yes      | The resource identifier to the policy assignment that will be exempt.
resourceGroup  | No       | The name of the Resource Group where the exemption will be scoped.
exemptionCategory | No       | The type of exemption.
description    | Yes      | A description for the policy exemption.
displayName    | Yes      | The display name of the policy exemption.
requestedBy    | Yes      | The team that own the resource that the exemption is being created for.
approvedBy     | Yes      | The team that approved the exemption.
expiresOnDate  | Yes      | The expiration date and time (in UTC ISO 8601 format yyyy-MM-ddTHH:mm:ssZ) of the policy exemption.
policyDefinitionReferenceIds | Yes      | An array of definition references that this resource is exempt from.

### exemptionNameSuffix

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

This value will be added as a suffix to the exemption name.

### assignmentId

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

The resource identifier to the policy assignment that will be exempt.

### resourceGroup

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

The name of the Resource Group where the exemption will be scoped.

### exemptionCategory

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

The type of exemption.

- Default value: `Waiver`

- Allowed values: `Waiver`, `Mitigated`

### description

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

A description for the policy exemption.

### displayName

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

The display name of the policy exemption.

### requestedBy

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

The team that own the resource that the exemption is being created for.

### approvedBy

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

The team that approved the exemption.

### expiresOnDate

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

The expiration date and time (in UTC ISO 8601 format yyyy-MM-ddTHH:mm:ssZ) of the policy exemption.

### policyDefinitionReferenceIds

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

An array of definition references that this resource is exempt from.

## Snippets

### Parameter file

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "metadata": {
        "template": "templates/policy-exemption/v1/template.json"
    },
    "parameters": {
        "exemptionNameSuffix": {
            "value": ""
        },
        "assignmentId": {
            "value": ""
        },
        "resourceGroup": {
            "value": "<resource_group_name>"
        },
        "exemptionCategory": {
            "value": "Waiver"
        },
        "description": {
            "value": "<description>"
        },
        "displayName": {
            "value": "<display_name>"
        },
        "requestedBy": {
            "value": "<requested_team>"
        },
        "approvedBy": {
            "value": "<approval_team>"
        },
        "expiresOnDate": {
            "value": "2021-04-28T00:00:00+10:00"
        },
        "policyDefinitionReferenceIds": {
            "value": []
        }
    }
}
```
