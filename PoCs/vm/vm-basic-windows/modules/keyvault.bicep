@description('Fixed Key Vault name. Must be 3-24 chars, globally unique, start with a letter, lowercase alphanumeric and hyphens.')
param keyVaultName string

param location string = resourceGroup().location
param tenantId string = subscription().tenantId

@description('Object ID of the user/service principal that should be granted full access to the Key Vault.')
param deployerObjectId string

@description('Name of the secret to store in the Key Vault.')
param secretName string

@description('Value of the secret to store in the Key Vault.')
@secure()
param secretValue string

resource keyVault 'Microsoft.KeyVault/vaults@2024-11-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      name: 'standard'
      family: 'A'
    }
    tenantId: tenantId
    enabledForTemplateDeployment: true
    accessPolicies: [
      {
        tenantId: tenantId
        objectId: deployerObjectId
        permissions: {
          keys: ['all']
          secrets: ['all']
          certificates: ['all']
        }
      }
    ]
  }
}

resource adminPasswordSecret 'Microsoft.KeyVault/vaults/secrets@2024-11-01' = {
  parent: keyVault
  name: secretName
  properties: {
    value: secretValue
  }
}

output keyVaultName string = keyVault.name
