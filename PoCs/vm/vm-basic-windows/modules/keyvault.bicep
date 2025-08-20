param keyVaultName string = 'myVMKeyVault'
param location string = 'swedencentral'
param tenantId string = subscription().tenantId

// Add: objectId of the user/service principal performing the deployment
param deployerObjectId string

// Append a stable unique suffix; scope it to subscription+RG+base name
var kvSuffix = uniqueString(subscription().id, resourceGroup().id, keyVaultName)
// Build final name: lower-case, hyphen + suffix, max 24 chars total
var keyVaultNameUnique = toLower('${take(keyVaultName, 24 - 1 - length(kvSuffix))}-${kvSuffix}')

resource keyVault 'Microsoft.KeyVault/vaults@2024-11-01' = {
  name: keyVaultNameUnique
  location: location
  properties: {
    sku: {
      name: 'standard'
      family: 'A'
    }
    tenantId: tenantId
    accessPolicies: [
      {
        tenantId: tenantId
        objectId: deployerObjectId
        permissions: {
          // Grant full rights
          keys: ['all']
          secrets: ['all']
          certificates: ['all']
        }
      }
    ]
  }
}
