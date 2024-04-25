param location string = resourceGroup().location
param bastionSubnetIpPrefix string = '10.0.2.0/26'
param bastionpublicipname string = 'bastionPublicIp'
param bastionHostName string = 'myBastionHost'
param vnetName string
param natgatewayName string

var bastionSubnetName  = 'AzureBastionSubnet'


resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: vnetName
}

resource natgateway 'Microsoft.Network/natGateways@2021-05-01' existing = {
  name: natgatewayName
}

resource bastionsubnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  parent: vnet
  name: bastionSubnetName
  properties: {
    addressPrefix: bastionSubnetIpPrefix
    natGateway: {
      id: natgateway.id
    }
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}



resource bastionPublicIp 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: bastionpublicipname
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

resource bastionHost 'Microsoft.Network/bastionHosts@2022-01-01' = {
  name: bastionHostName
  location: location
  dependsOn: [
    vnet
    bastionsubnet
  ]
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: bastionsubnet.id
          }
          publicIPAddress: {
            id: bastionPublicIp.id
          }
        }
      }
    ]
  }
}
