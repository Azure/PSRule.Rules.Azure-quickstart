// Create or update a Storage Account
targetScope = 'resourceGroup'
metadata name = 'Storage Account'
metadata description = 'Deploys and configures a Storage Account, optionally with a Private Endpoint. When Private Endpoints are enabled, access from the Internet is blocked.'
metadata version = '1.0.0'

// ----------
// PARAMETERS
// ----------

@minLength(3)
@maxLength(24)
@sys.description('The name of the Storage Account.')
#disable-next-line BCP334
param name string = take(deployment().name, 24)

@metadata({
  strongType: 'location'
  example: 'eastus'
  ignore: true
})
@sys.description('The Azure region to deploy to.')
param location string = resourceGroup().location

@allowed([
  'StorageV2'
  'FileStorage'
])
@sys.description('The type of storage to use.')
param storageKind string = 'StorageV2'

@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
])
@sys.description('Create the Storage Account as LRS, GRS, or ZRS.')
param sku string = 'Standard_GRS'

@metadata({
  example: [
    {
      name: 'CONTAINER_NAME'
      publicAccess: 'None'
      metadata: {}
    }
  ]
})
@sys.description('An list of storage containers to create on the storage account. [See docs](https://npccloud.com/docs)')
param containers containerType[] = []

@metadata({
  example: {
    enabled: true
    name: 'RULE_NAME'
    type: 'Lifecycle'
    definition: {
      actions: {
        baseBlob: {
          delete: {
            daysAfterModificationGreaterThan: 7
          }
        }
      }
      filters: {
        blobTypes: [
          'blockBlob'
        ]
        prefixMatch: [
          'logs/'
        ]
      }
    }
  }
})
@sys.description('An array of lifecycle management policies for the Storage Account.')
param lifecycleRules object[] = []

@minValue(0)
@maxValue(365)
@metadata({
  example: 7
})
@sys.description('The number of days to retain deleted blobs. When set to 0, soft delete is disabled.')
param blobSoftDeleteDays int = 7

@minValue(0)
@maxValue(365)
@metadata({
  example: 7
})
@sys.description('The number of days to retain deleted containers. When set to 0, soft delete is disabled.')
param containerSoftDeleteDays int = 7

@metadata({
  example: [
    {
      name: 'SHARE_NAME'
      shareQuota: 5
      metadata: {}
    }
  ]
})
@sys.description('An array of file shares to create on the Storage Account.')
param shares object[] = []

@metadata({
  ignore: true
})
@sys.description('Determines if large file shares are enabled. This can not be disabled once enabled.')
param useLargeFileShares bool = false

@minValue(0)
@maxValue(365)
@metadata({
  example: 7
})
@sys.description('The number of days to retain deleted shares. When set to 0, soft delete is disabled.')
param shareSoftDeleteDays int = 7

@allowed([
  'Deny'
  'Allow'
])
@sys.description('Deny or allow network traffic unless explicitly allowed.')
param defaultFirewallAction string = 'Deny'

@metadata({
  example: [
    'x.x.x.x'
  ]
})
@sys.description('Firewall rules to permit specific IP addresses access to storage.')
param firewallIPRules string[] = []

@metadata({
  example: [
    '/subscriptions/SUBSCRIPTION_ID/resourceGroups/RESOURCE_GROUP_NAME/providers/Microsoft.Network/virtualNetworks/VNET_NAME/subnets/SUBNET_NAME'
  ]
})
@sys.description('A list of resource IDs to subnets that are permitted access to storage. For each entry, a service endpoint firewall rule is created for the subnet.')
param firewallVirtualNetworkRules string[] = []

@sys.description('Determines if any containers can be configured with the anonymous access types of blob or container. By default, anonymous access to blobs and containers is disabled (`false`).')
param allowBlobPublicAccess bool = false

@sys.description('Determines if access keys and SAS tokens can be used to access storage. By default, access keys and SAS tokens are disabled (`false`).')
param allowSharedKeyAccess bool = false

@sys.description('Determines if the Azure Portal defaults to OAuth.')
param defaultToOAuthAuthentication bool = true

@sys.maxLength(0)
@sys.maxLength(5)
@sys.description('Configures any CORS rules to apply to blob requests.')
param cors corsRuleType[] = []

@metadata({
  example: [
    {
      principalId: 'OBJECT_ID'
      description: 'DESCRIPTION'
      principalType: 'Group'
      role: 'Contributor'
    }
  ]
})
@sys.description('A list of additional role assignments for the Storage Account.')
param assignments assignmentType[] = []

@metadata({
  strongType: 'Microsoft.Network/virtualNetworks/subnets'
})
@sys.description('The subnet to connect a private endpoint.')
param subnetId string = ''

@sys.description('Additional tags to apply to the resource. Tags from the resource group will automatically be applied.')
param tags object = {}

// -----
// TYPES
// -----

type corsRuleType = {
  @sys.description('A list of headers allowed to be part of the cross-origin request.')
  allowedHeaders: string[]

  @sys.description('A list of HTTP methods that are allowed to be executed by the origin.')
  allowedMethods: ('CONNECT' | 'DELETE' | 'GET' | 'HEAD' | 'MERGE' | 'OPTIONS' | 'PATCH' | 'POST' | 'PUT' | 'TRACE')[]

  @sys.description('A list of origin domains that will be allowed via CORS, or `*` to allow all domains.')
  allowedOrigins: string[]

  @sys.description('A list of response headers to expose to CORS clients.')
  exposedHeaders: string[]

  @sys.description('The number of seconds that the client/ browser should cache a preflight response.')
  maxAgeInSeconds: int
}

type assignmentType = {
  @sys.minLength(36)
  @sys.maxLength(36)
  @sys.description('The GUID of the principal to assign.')
  principalId: string

  @sys.description('A description for the assignment.')
  description: string?

  @sys.description('The type of principal.')
  principalType: 'ServicePrincipal' | 'Group' | 'User' | 'ForeignGroup' | 'Device'

  @sys.description('''
  The a name or GUID for the role to assign. Common role assignments include:
  
  - `Owner`
  - `Contributor`
  - `Reader`
  - `User Access Administrator`
  - `Storage Account Contributor`
  - `Storage Account Key Operator Service Role`
  - `Storage Blob Data Contributor`
  - `Storage Blob Data Owner`
  - `Storage Blob Data Reader`
  - `Storage File Data SMB Share Contributor`
  - `Storage File Data SMB Share Elevated Contributor`
  - `Storage File Data SMB Share Reader`

  ''')
  role: string
}

type containerType = {
  @sys.description('The name of the container.')
  name: string

  @sys.description('Determines if the container is exposed without authentication.')
  publicAccess: 'Blob' | 'Container' | 'None' | null

  @sys.description('Additional metadata to assign to the container.')
  metadata: object?
}

// ---------
// VARIABLES
// ---------

// Calculate storage account name using existing complex naming rules
var storageAccountName = toLower(name)

// Always use large file shares if using FileStorage
var configureLargeFileShares = storageKind == 'FileStorage' ? true : useLargeFileShares
var largeFileSharesState = configureLargeFileShares ? 'Enabled' : 'Disabled'

// Configure private endpoints based on blob or file
var blobEndpoint = [
  'blob'
]
var fileEndpoint = [
  'file'
]
var isFileStorage = storageKind == 'FileStorage'
var usePrivateEndpoint = !empty(subnetId)
var endpoints = !usePrivateEndpoint ? [] : isFileStorage ? fileEndpoint : blobEndpoint

// Configure tags
var allTags = union(resourceGroup().tags, tags)

// ---------
// RESOURCES
// ---------

@sys.description('Create or update a Storage Account.')
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: sku
  }
  kind: storageKind
  properties: {
    networkAcls: {
      defaultAction: usePrivateEndpoint ? 'Deny' : defaultFirewallAction
      bypass: 'AzureServices'
      ipRules: [for item in firewallIPRules: {
        action: 'Allow'
        value: item
      }]
      virtualNetworkRules: [for item in firewallVirtualNetworkRules: {
        action: 'Allow'

        #disable-next-line use-resource-id-functions
        id: item
      }]
      resourceAccessRules: [
        {
          tenantId: tenant().tenantId

          #disable-next-line use-resource-id-functions
          resourceId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Security/datascanners/StorageDataScanner'
        }
      ]
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          enabled: true
        }
        blob: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
    largeFileSharesState: largeFileSharesState
    allowBlobPublicAccess: allowBlobPublicAccess
    allowSharedKeyAccess: allowSharedKeyAccess
    defaultToOAuthAuthentication: allowSharedKeyAccess ? true : defaultToOAuthAuthentication
    minimumTlsVersion: 'TLS1_2'
    publicNetworkAccess: usePrivateEndpoint ? 'Disabled' : 'Enabled'
  }
  tags: allTags
}

@sys.description('Configure blob services for the Storage Account.')
resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    cors: {
      corsRules: cors ?? []
    }
    deleteRetentionPolicy: {
      enabled: blobSoftDeleteDays > 0

      #disable-next-line BCP329
      days: blobSoftDeleteDays > 0 ? blobSoftDeleteDays : null
    }
    containerDeleteRetentionPolicy: {
      enabled: containerSoftDeleteDays > 0

      #disable-next-line BCP329
      days: containerSoftDeleteDays > 0 ? containerSoftDeleteDays : null
    }
  }
}

@sys.description('Configure file services for the Storage Account.')
resource fileServices 'Microsoft.Storage/storageAccounts/fileServices@2023-01-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    shareDeleteRetentionPolicy: {
      enabled: shareSoftDeleteDays > 0

      #disable-next-line BCP329
      days: shareSoftDeleteDays > 0 ? shareSoftDeleteDays : null
    }
  }
}

@sys.description('Create or update blob containers for the Storage Account.')
resource storageContainers 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = [for item in containers: if (!empty(containers)) {
  parent: blobServices
  name: item.name
  properties: {
    metadata: contains(item, 'metadata') ? item.metadata : {}
    publicAccess: contains(item, 'publicAccess') ? item.publicAccess : 'None'
  }
}]

@sys.description('Create or update file shares for the Storage Account.')
resource storageShares 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-01-01' = [for item in shares: if (!empty(shares)) {
  parent: fileServices
  name: item.name
  properties: {
    metadata: contains(item, 'metadata') ? item.metadata : {}
    shareQuota: contains(item, 'shareQuota') ? item.shareQuota : 5120
  }
}]

@sys.description('Configure policies for managing blob lifecycle for the Storage Account.')
resource managementPolicies 'Microsoft.Storage/storageAccounts/managementPolicies@2023-01-01' = if (!empty(lifecycleRules)) {
  parent: storageAccount
  name: 'default'
  properties: {
    policy: {
      rules: lifecycleRules
    }
  }
}

@sys.description('Create or update a Private Endpoint for the Storage Account.')
module pe '.bicep/pe.bicep' = [for endpoint in endpoints: {
  name: 'pend-${storageAccountName}-${endpoint[0]}-001'
  params: {
    name: 'pend-${storageAccountName}-${endpoint[0]}-001'
    location: location
    resourceId: storageAccount.id
    groupId: endpoint
    subnetId: subnetId
    tags: tags
  }
}]

@sys.description('Create or update role assignments for the Storage Account.')
module rbac '.bicep/rbac.bicep' = [for assignment in assignments: {
  name: 'assignment-${uniqueString(storageAccount.id, assignment.principalId, assignment.role)}'
  params: {
    principalId: assignment.principalId
    description: contains(assignment, 'description') ? assignment.description : ''
    principalType: assignment.principalType
    role: assignment.role
    resourceName: storageAccount.name
  }
}]

// -------
// OUTPUTS
// -------

@sys.description('A unique identifier for the Storage Account.')
output id string = storageAccount.id

@sys.description('The name of the Storage Account.')
output storageAccountName string = storageAccountName

@sys.description('The name of the Resource Group where the Storage Account is deployed.')
output resourceGroupName string = resourceGroup().name

@sys.description('The guid for the subscription where the Storage Account is deployed.')
output subscriptionId string = subscription().subscriptionId

@sys.description('The primary blob endpoint for the Storage Account.')
output blobEndpoint string = isFileStorage ? '' : storageAccount.properties.primaryEndpoints.blob
