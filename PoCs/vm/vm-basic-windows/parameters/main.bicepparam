using '../main.bicep'

// Resolved by deployment-pipeline.ps1 (sets these env vars before invoking az deployment)
//   SUBSCRIPTION_ID   - subscription containing the bootstrap Key Vault
//   KV_NAME           - name of the bootstrap Key Vault holding the admin password
//   KV_RESOURCE_GROUP - resource group of the bootstrap Key Vault

param resourceGroupName = 'poc-vm-basic-windows-rg'
param deployVm = true
param adminPassword = az.getSecret(
  readEnvironmentVariable('SUBSCRIPTION_ID'),
  readEnvironmentVariable('KV_RESOURCE_GROUP'),
  readEnvironmentVariable('KV_NAME'),
  'vm-admin-password'
)
