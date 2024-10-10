targetScope = 'subscription'

param location string = 'swedencentral'
param rgName string = 'myResourceGroup'
var vnetName = 'myVnet'
var vnetAddressPrefix = '10.0.0.0/16'
var subnetName = 'mySubnet'
var subnetAddressPrefix = '10.0.0.0/24'

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: rgName
  location: location
}

module vnet './vnet.bicep' = {
  name: 'vnetModule'
  scope: rg
  params: {
    location: location
    vnetName: vnetName
    vnetAddressPrefix: vnetAddressPrefix
    subnetName: subnetName
    subnetAddressPrefix: subnetAddressPrefix
  }
}
