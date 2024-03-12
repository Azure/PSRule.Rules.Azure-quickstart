// Create or update a Private Endpoint for the Storage Account.

// ----------
// PARAMETERS
// ----------

@description('The name of the Private Endpoint.')
param name string

@metadata({
  strongType: 'location'
  example: 'eastus'
})
@description('The Azure region to deploy to.')
param location string

@description('The unique resource identifer for the resource to expose through the Private Endpoint.')
param resourceId string

@allowed([
  'blob'
  'file'
  'table'
  'queue'
])
@description('The sub-resources to register the Private Endpoint for.')
param groupId string

@metadata({
  strongType: 'Microsoft.Network/virtualNetworks/subnets'
})
@description('The unique resource identifer for the subnet to join the private endpoint to.')
param subnetId string

@metadata({
  strongType: 'Microsoft.Network/privateDnsZones'
})
@description('The private DNS zone to register the private endpoint within.')
param privateDnsZoneId string = ''

@description('Tags to apply to the resource.')
param tags object

// ---------
// VARIABLES
// ---------

// ---------
// RESOURCES
// ---------

@description('Create or update a Private Endpoint for a resource.')
resource endpoint 'Microsoft.Network/privateEndpoints@2023-04-01' = {
  location: location
  name: name
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: name
        properties: {
          privateLinkServiceId: resourceId
          groupIds: [
            groupId
          ]
        }
      }
    ]
  }
  tags: tags
}

@description('Configures DNS for the Private Endpoint.')
resource endpointGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-04-01' = if (!empty(privateDnsZoneId)) {
  parent: endpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: replace(last(split(privateDnsZoneId, '/')), '.', '-')
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}

// -------
// OUTPUTS
// -------

@description('A unique identifier for the Private Endpoint.')
output id string = endpoint.id

@description('The name of the associated Private DNS Zone.')
output privateDnsZone string = last(split(privateDnsZoneId, '/'))

@description('The name of the Resource Group where the Private Endpoint is deployed.')
output resourceGroupName string = resourceGroup().name

@description('The guid for the subscription where the Private Endpoint is deployed.')
output subscriptionId string = subscription().subscriptionId
