// Configure the Virtual Machine resource

// ----------
// PARAMETERS
// ----------

@sys.description('The name of the virtual machine.')
param name string

@sys.description('The Azure region to deploy to.')
param location string

@sys.description('The SKU of the virtual machine.')
param size string

@sys.description('The publisher of the VM image to deploy.')
param imagePublisher string

@sys.description('The name of the offer of the VM image to deploy.')
param imageOffer string

@sys.description('The VM image SKU to deploy.')
param imageSKU string

@sys.description('A User Assigned Managed Identity to configure.')
param identityId string

@sys.description('The subnet to connect the VM.')
param subnetId string

@sys.description('The workspace to store monitoring data.')
param workspaceId string

@sys.description('The maintenance configuration to assign.')
param maintenanceConfigurationId string

@secure()
@sys.description('The username of the local administrator account.')
param adminUsername string

@secure()
@sys.description('The default password assigned to the local administrator account.')
param adminPassword string

@sys.description('Attach existing disks or create empty disks.')
param diskCreateOption string

@sys.description('An array of managed disks to create or attach.')
param dataDisks array

@sys.description('Determines if accelerated networking is enabled for the VM.')
param useAcceleratedNetworking bool

@sys.description('Determines if Network Watcher extension is configured for the VM.')
param useNetworkWatcher bool

@sys.description('Determines if Azure Policy Guest Configuration extension is configured for the VM.')
param useAzurePolicy bool

@sys.description('Determines if SQL Server IaaS extension is configured for the VM.')
param useSqlServer bool

@sys.description('Tags to apply to the resource.')
param tags object

// ---------
// VARIABLES
// ---------

var nicName = toUpper('${name}-NIC-01')
var osDiskName = '${toUpper(name)}-os'

// Configure VM availablity
var useAvailabilitySet = true
var availabilitySetName = toUpper('${vmNamePrefix}-AVSET01')
var faultDomains = 2
var updateDomains = 5

// Map managed disks for VM
var managedDisks = [
  for (disk, index) in dataDisks: {
    name: disk.?name ?? '${name}-Data${index}'
    sku: disk.?sku ?? 'Standard_LRS'
    properties: {
      creationData: {
        createOption: 'Empty'
      }
      diskSizeGB: disk.diskSizeGB
    }
  }
]

// Map data disks for VM
var vmDisks = [
  for (disk, index) in dataDisks: {
    lun: index
    createOption: 'Attach'
    caching: disk.?caching ?? (startsWith(disk.?sku ?? 'Standard_LRS', 'Standard_') ? 'None' : 'ReadOnly')
    deleteOption: disk.?deleteOption ?? 'Detach'
    managedDisk: {
      id: md[index].id
    }
    writeAcceleratorEnabled: disk.?writeAcceleratorEnabled ?? false
  }
]

var storageProfileOption = {
  Empty: {
    imageReference: {
      publisher: imagePublisher
      offer: imageOffer
      sku: imageSKU
      version: 'latest'
    }
    osDisk: {
      name: osDiskName
      caching: 'ReadWrite'
      createOption: 'FromImage'
    }
    dataDisks: vmDisks
  }
  Attach: {
    osDisk: {
      osType: 'Windows'
      name: osDiskName
      managedDisk: {
        id: '${resourceGroup().id}/providers/Microsoft.Compute/disks/${osDiskName}'
      }
      caching: 'ReadWrite'
      createOption: 'Attach'
    }
    dataDisks: vmDisks
  }
}
var storageProfile = storageProfileOption[diskCreateOption]

// VM naming
var vmNamePrefix = take(name, (length(name) - 2))

// Configure tags
var vmTags = tags

// ---------
// RESOURCES
// ---------

@sys.description('Create or update an Availability Set for the VM deployment.')
resource availabilitySet 'Microsoft.Compute/availabilitySets@2023-03-01' = if (useAvailabilitySet) {
  name: availabilitySetName
  location: location
  tags: tags
  sku: {
    name: 'Aligned'
  }
  properties: {
    platformFaultDomainCount: faultDomains
    platformUpdateDomainCount: updateDomains
  }
}

@sys.description('Create or update a Network Interface using dynamic addressing.')
resource nic 'Microsoft.Network/networkInterfaces@2023-02-01' = {
  name: nicName
  location: location
  tags: tags
  properties: {
    enableIPForwarding: false
    enableAcceleratedNetworking: useAcceleratedNetworking
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}

@sys.description('Create or update Managed Disks for the VM.')
resource md 'Microsoft.Compute/disks@2023-01-02' = [
  for item in managedDisks: if (length(managedDisks) > 0) {
    name: item.name
    location: location
    tags: tags
    sku: {
      name: item.sku
    }
    properties: item.properties
  }
]

@sys.description('Create or update a Virtual Machine (VM).')
resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: name
  location: location
  tags: vmTags
  identity: empty(identityId)
    ? {
        type: 'SystemAssigned'
      }
    : {
        type: 'SystemAssigned, UserAssigned'
        userAssignedIdentities: {
          '${identityId}': {}
        }
      }
  properties: {
    hardwareProfile: {
      vmSize: size
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    availabilitySet: {
      id: availabilitySet.id
    }
    osProfile: diskCreateOption == 'Empty'
      ? {
          adminUsername: adminUsername
          adminPassword: adminPassword
          computerName: name
        }
      : null
    storageProfile: storageProfile
  }
}

@sys.description('Configure a maintenance configuration for the VM.')
resource config 'Microsoft.Maintenance/configurationAssignments@2022-11-01-preview' = if (!empty(maintenanceConfigurationId)) {
  name: 'default'
  location: location
  scope: vm
  properties: {
    maintenanceConfigurationId: maintenanceConfigurationId
  }
}

@sys.description('Configure the Microsoft Monitoring Agent extension for the VM.')
resource monitoringExtension 'Microsoft.Compute/virtualMachines/extensions@2023-03-01' = {
  parent: vm
  name: 'Microsoft.EnterpriseCloud.Monitoring'
  location: location
  properties: {
    publisher: 'Microsoft.EnterpriseCloud.Monitoring'
    type: 'MicrosoftMonitoringAgent'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    settings: {
      workspaceId: reference(workspaceId, '2021-06-01').customerId
      stopOnMultipleConnections: false
    }
    protectedSettings: {
      workspaceKey: listKeys(workspaceId, '2021-06-01').primarySharedKey
    }
  }
}

@sys.description('Configure the Dependency Agent for the VM.')
resource dependencyAgentWindows 'Microsoft.Compute/virtualMachines/extensions@2023-03-01' = {
  parent: vm
  name: 'DependencyAgentWindows'
  location: location
  properties: {
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    publisher: 'Microsoft.Azure.Monitoring.DependencyAgent'
    type: 'DependencyAgentWindows'
    typeHandlerVersion: '9.10'
  }
}

@sys.description('Configure the Network Watcher Agent for the VM.')
resource networkWatcherExtension 'Microsoft.Compute/virtualMachines/extensions@2023-03-01' = if (useNetworkWatcher) {
  parent: vm
  name: 'AzureNetworkWatcherExtension'
  location: location
  properties: {
    autoUpgradeMinorVersion: true
    publisher: 'Microsoft.Azure.NetworkWatcher'
    type: 'NetworkWatcherAgentWindows'
    typeHandlerVersion: '1.4'
  }
}

@sys.description('Configure the Azure Policy Guest Configuration Agent for the VM.')
resource azurePolicyExtension 'Microsoft.Compute/virtualMachines/extensions@2023-03-01' = if (useAzurePolicy) {
  parent: vm
  name: 'AzurePolicyforWindows'
  location: location
  properties: {
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    publisher: 'Microsoft.GuestConfiguration'
    type: 'ConfigurationforWindows'
    typeHandlerVersion: '1.1'
  }
}

@sys.description('Configure the SQL IaaS Agent for the VM.')
resource sqlServerExtension 'Microsoft.Compute/virtualMachines/extensions@2023-03-01' = if (useSqlServer) {
  parent: vm
  name: 'SqlIaasExtension'
  location: location
  properties: {
    autoUpgradeMinorVersion: true
    publisher: 'Microsoft.SqlServer.Management'
    type: 'SqlIaaSAgent'
    typeHandlerVersion: '2.0'
    settings: {
      sqlServerLicenseType: 'PAYG'
    }
  }
}

// -------
// OUTPUTS
// -------

@sys.description('A unique identifier for the VM.')
output id string = vm.id

@sys.description('The name of the VM.')
output name string = vm.name
