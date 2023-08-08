// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

targetScope = 'resourceGroup'

metadata name = 'Storage Account'
metadata description = 'Create or update an Storage Account.'

@sys.description('The name of the Storage Account.')
param name string

@metadata({
  strongType: 'location'
})
@sys.description('The Azure region to deploy to.')
param location string = resourceGroup().location

@allowed([
  'Standard_GRS'
  'Standard_LRS'
])
@sys.description('Create the Storage Account as LRS or GRS.')
param sku string = 'Standard_GRS'

@sys.description('Determines if any containers can be configured with the anonymous access types of blob or container.')
param allowBlobPublicAccess bool = true

@metadata({
  example: {
    service: '<service_name>'
    env: 'prod'
  }
})
@sys.description('Tags to apply to the resource.')
param tags object = resourceGroup().tags

@sys.description('Create or update an Storage Account.')
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

@sys.description('Configure Blob Services for a Storage Account.')
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

@sys.description('Configure File Services for a Storage Account.')
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
