// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

@description('The name of the Storage Account.')
param name string

@description('The Azure region to deploy to.')
@metadata({
  strongType: 'location'
})
param location string = resourceGroup().location

@allowed([
  'Standard_GRS'
  'Standard_LRS'
])
@description('Create the Storage Account as LRS or GRS.')
param sku string = 'Standard_GRS'

@description('Determines if any containers can be configured with the anonymous access types of blob or container.')
param allowBlobPublicAccess bool = true

@description('Tags to apply to the resource.')
@metadata({
  example: {
    service: '<service_name>'
    env: 'prod'
  }
})
param tags object = resourceGroup().tags

// Define a Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: name
  location: location
  sku: {
    name: sku
  }
  kind: 'StorageV2'
  properties: {
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Deny'
    }
    supportsHttpsTrafficOnly: true
    accessTier: 'Hot'
    allowBlobPublicAccess: allowBlobPublicAccess
    minimumTlsVersion: 'TLS1_2'
  }
  tags: tags
}

resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2019-06-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      enabled: true
      days: 7
    }
    containerDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

resource fileServices 'Microsoft.Storage/storageAccounts/fileServices@2019-06-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    shareDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}
