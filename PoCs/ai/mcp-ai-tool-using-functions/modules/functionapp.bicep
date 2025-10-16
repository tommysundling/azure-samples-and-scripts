// Azure Function App module with Flex Consumption plan (FC1)
param location string
param functionAppName string
param storageAccountName string
param appInsightsConnectionString string
param tags object = {}

// Reference existing storage account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: storageAccountName
}

// Flex Consumption Function App (FC1)
resource functionApp 'Microsoft.Web/sites@2023-12-01' = {
  name: functionAppName
  location: location
  tags: tags
  kind: 'functionapp,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: null  // No App Service Plan needed for Flex Consumption
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage__accountName'
          value: storageAccount.name
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsightsConnectionString
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet-isolated'
        }
      ]
      linuxFxVersion: 'DOTNET-ISOLATED|8.0'
      cors: {
        allowedOrigins: [
          'https://portal.azure.com'
        ]
      }
      http20Enabled: true
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
    }
    httpsOnly: true
  }
}

// Flex Consumption-specific configuration
resource functionAppConfig 'Microsoft.Web/sites/config@2023-12-01' = {
  parent: functionApp
  name: 'web'
  properties: {
    functionAppScaleLimit: 100
    minimumElasticInstanceCount: 0
    instanceMemoryMB: 2048
  }
}

// RBAC: Grant Function App access to Storage Account
resource storageRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, functionApp.id, 'StorageBlobDataOwner')
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b') // Storage Blob Data Owner
    principalId: functionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource queueContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, functionApp.id, 'StorageQueueDataContributor')
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '974c5e8b-45b9-4653-ba55-5f855dd0fb88') // Storage Queue Data Contributor
    principalId: functionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

output functionAppId string = functionApp.id
output functionAppName string = functionApp.name
output functionAppPrincipalId string = functionApp.identity.principalId
output functionAppHostName string = functionApp.properties.defaultHostName
output mcpEndpoint string = 'https://${functionApp.properties.defaultHostName}/runtime/webhooks/mcp'
