
targetScope = 'subscription'

param resourceGroupName string
param resourceGroupLocation string = 'swedencentral'

param vnetName string

resource resourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: resourceGroupLocation
  properties: {
    
  }
}

module vnetModule 'vnet.bicep' = {
  scope: resourceGroup
  name: 'vnet'
  params: {
    vnetName: vnetName
    location: resourceGroup.location
  }
}
