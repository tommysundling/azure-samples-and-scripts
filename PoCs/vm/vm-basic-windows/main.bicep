targetScope = 'subscription'

param location string = 'swedencentral'
param resourceGroupName string = 'poc-vm-basic-windows'
param deployVm bool = true

param vnetName string = 'myVnet'
param natgatewayName string = 'natGateway'
param vmName string = 'windowsvm'
param adminUsername string = 'tommy'
@secure()
param adminPassword string


resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: location
}

// module vnetDeployment './vnet.bicep' = {
//   name: 'vnetDeployment'
//   scope: rg
//   params: {
//     location: location
//     vnetName: vnetName
//     natgatewayName: natgatewayName
//   }
// }
// output vnet object = vnetDeployment.outputs.vnetObj

// module bastionDeployment './bastion.bicep' = {
//   name: 'bastionDeployment'
//   scope: rg
//   params: {
//     vnetName: vnetName
//     natgatewayName: natgatewayName
//     location: location
//   }
//   dependsOn: [
//     vnetDeployment
//   ]
// }

module vmDeployment './vm.bicep' = if(deployVm == true) {
  name: 'Deploy-VM'
  scope: rg
  params: {
    location: location
    vnetName: vnetName
    vmSubnetName: 'default'
    vmName: vmName
    adminUsername: adminUsername
    adminPassword: adminPassword
  }
}
