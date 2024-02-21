targetScope = 'subscription'

param location string = 'swedencentral'
param resourceGroupName string = 'poc-vm-basic-windows'

param vnetName string = 'vm-basic-windows-vnet'
param vmName string = 'vm-basic-windows-vm'
param adminUsername string = 'tommy'
@secure()
param adminPassword string


resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: location
}

module vnet 'solution.bicep' = {
  name: 'Deploy-VM'
  scope: rg
  params: {
    location: location
    vnetName: vnetName
    vmName: vmName
    adminUsername: adminUsername
    adminPassword: adminPassword
  }
}
