targetScope = 'resourceGroup'

param vnetName string
param vnetResourceGroupName string
param dnsZoneName string

module privateDnsZone 'private-dns-zone.bicep' = {
  name: 'privateDnsZoneDeployment'
  params: {
    vnetName: vnetName
    dnsZoneName: dnsZoneName
    vnetResourceGroupName: vnetResourceGroupName
  }
}

output privateDnsZoneId string = privateDnsZone.outputs.dnsZoneId
output vnetLinkId string = privateDnsZone.outputs.vnetLinkId
