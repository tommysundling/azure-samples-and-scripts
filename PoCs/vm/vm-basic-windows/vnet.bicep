param location string = resourceGroup().location
param vnetName string
param natpublicipname string = 'natPublicIp'
param natgatewayName string


resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
    ]
  }
}

resource vmSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  parent: vnet
  name: 'default'
  properties: {
    addressPrefix: '10.0.0.0/24'
    natGateway: {
      id: natgateway.id
    }
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}


// Subnet for Azure NAT Gateway
// resource natsubnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
//   parent: vnet
//   name: 'nat'
//   properties: {
//     addressPrefix: '10.0.1.0/24'
//     natGateway: {
//       id: natgateway.id
//     }
//     privateEndpointNetworkPolicies: 'Enabled'
//     privateLinkServiceNetworkPolicies: 'Enabled'
//   }
// }

// Public IP for Azure NAT Gateway
resource natpublicip 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: natpublicipname
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
  }
}

resource natgateway 'Microsoft.Network/natGateways@2021-05-01' = {
  name: natgatewayName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    idleTimeoutInMinutes: 4
    publicIpAddresses: [
      {
        id: natpublicip.id
      }
    ]
  }
}

output vnetObj object = vnet
