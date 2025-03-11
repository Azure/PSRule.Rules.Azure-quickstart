// Create or update a Virtual Machine
targetScope = 'resourceGroup'
metadata name = 'Virtual Machine - Windows Server'
metadata description = 'Deploys and configures a Windows Server Virtual Machine. VM will automatically domain join and configure monitoring.'
metadata version = '1.0.0'

// ----------
// PARAMETERS
// ----------

@sys.description('The name of the virtual machine.')
param name string

@metadata({
  strongType: 'location'
  example: 'eastus'
  ignore: true
})
@sys.description('The Azure region to deploy to.')
param location string = resourceGroup().location

@allowed([
  '2022-Datacenter-Core'
  '2022-Datacenter'
])
@sys.description('The operating system image to deploy.')
param imageSKU string

@allowed([
  'Standard_D2s_v3'
  'Standard_D2as_v4'
  'Standard_D2ds_v4'
  'Standard_D4s_v3'
  'Standard_D4as_v4'
  'Standard_D4ds_v4'
  'Standard_D8s_v3'
  'Standard_D8as_v4'
  'Standard_D8ds_v4'
  'Standard_E2s_v3'
  'Standard_E2as_v4'
  'Standard_E2ds_v4'
  'Standard_E4s_v3'
  'Standard_E4as_v4'
  'Standard_E4ds_v4'
  'Standard_E8s_v3'
  'Standard_E8as_v4'
  'Standard_E8ds_v4'
  'Standard_F2s_v2'
  'Standard_F4s_v2'
  'Standard_F8s_v2'
  'Standard_F16s_v2'
  'Standard_L8s_v2'
  'Standard_L16s_v2'
])
@sys.description('The SKU of the virtual machine.')
param size string

@metadata({
  strongType: 'Microsoft.ManagedIdentity/userAssignedIdentities'
})
@sys.description('A User Assigned Managed Identity to configure.')
param identityId string = ''

@metadata({
  strongType: 'Microsoft.Network/virtualNetworks/subnets'
})
@sys.description('The subnet to connect the VM.')
param subnetId string

@metadata({
  strongType: 'Microsoft.OperationalInsights/workspaces'
  example: '/subscriptions/SUBSCRIPTION_ID/resourceGroups/RESOURCE_GROUP_NAME/providers/Microsoft.OperationalInsights/workspaces/WORKSPACE_NAME'
})
@sys.description('The workspace to store monitoring data.')
param workspaceId string = ''

@sys.description('The maintenance configuration to assign.')
param maintenanceConfigurationId string = ''

@secure()
@sys.description('The default administrator username for the VM.')
param adminUsername string

@secure()
@sys.description('The default administrator password for the VM.')
param adminPassword string

@allowed([
  'Empty'
  'Attach'
])
@sys.description('Attach existing disks or create empty disks.')
param diskCreateOption string = 'Empty'

@metadata({
  example: [
    {
      diskSizeGB: 32
      sku: 'Standard_LRS'
      caching: 'ReadOnly'
    }
  ]
})
@sys.description('An array of managed disks to create or attach.')
param dataDisks array = []

@sys.description('Determines if accelerated networking is enabled for the VM.')
param useAcceleratedNetworking bool = false

@sys.description('Determines if Network Watcher extension is configured for the VM.')
param useNetworkWatcher bool = false

@sys.description('Determines if Azure Policy Guest Configuration extension is configured for the VM.')
param useAzurePolicy bool = false

@sys.description('Determines if SQL Server IaaS extension is configured for the VM.')
param useSqlServer bool = false

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
@sys.description('A list of additional role assignments for the Virtual Machine.')
param assignments array = []

@sys.description('Tags to apply to the resource.')
param tags object = resourceGroup().tags

// ---------
// VARIABLES
// ---------

// Get the publisher and offer details for the specific VM image to use
var imagePublisher = 'MicrosoftWindowsServer'
var imageOffer = 'WindowsServer'

// ---------
// RESOURCES
// ---------

@sys.description('Create or update a Virtual Machine (VM).')
module vm '.bicep/vm.bicep' = {
  name: 'vm-${name}'
  params: {
    name: name
    location: location
    size: size
    imagePublisher: imagePublisher
    imageOffer: imageOffer
    imageSKU: imageSKU
    identityId: identityId
    subnetId: subnetId
    workspaceId: workspaceId
    maintenanceConfigurationId: maintenanceConfigurationId
    adminUsername: adminUsername
    adminPassword: adminPassword
    diskCreateOption: diskCreateOption
    dataDisks: dataDisks
    useAcceleratedNetworking: useAcceleratedNetworking
    useNetworkWatcher: useNetworkWatcher
    useAzurePolicy: useAzurePolicy
    useSqlServer: useSqlServer
    tags: tags
  }
}

@sys.description('Create or update role assignments for the Virtual Machine.')
module rbac '.bicep/rbac.bicep' = [
  for assignment in assignments: {
    name: 'assignment-${uniqueString(resourceId('Microsoft.Compute/virtualMachines', name), assignment.principalId, assignment.role)}'
    params: {
      principalId: assignment.principalId
      description: assignment.?description ?? ''
      principalType: assignment.principalType
      role: assignment.role
      resource: vm.outputs.name
    }
  }
]

// -------
// OUTPUTS
// -------

@sys.description('A unique identifier for the VM.')
output id string = vm.outputs.id

@sys.description('The name of the VM.')
output name string = name

@sys.description('The name of the Resource Group where the VM is deployed.')
output resourceGroupName string = resourceGroup().name

@sys.description('The guid for the subscription where the VM is deployed.')
output subscriptionId string = subscription().subscriptionId
