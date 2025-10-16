targetScope = 'subscription'

// Parameters
@description('The Azure region for all resources')
param location string = 'swedencentral'

@description('The environment name (e.g., dev, test, prod)')
@maxLength(8)
param environmentName string = 'dev'

@description('The workload name')
param workloadName string = 'mcphello'

@description('Resource tags')
param tags object = {
  Environment: environmentName
  Workload: workloadName
  ManagedBy: 'Bicep'
  Purpose: 'MCP-Hello-AI-Function'
}

// Variables
var resourceGroupName = 'rg-${workloadName}-${environmentName}-${location}'
var storageAccountName = 'st${workloadName}${environmentName}${uniqueString(subscription().id, resourceGroupName)}'
var functionAppName = 'func-${workloadName}-${environmentName}-${uniqueString(subscription().id, resourceGroupName)}'
var appInsightsName = 'appi-${workloadName}-${environmentName}'
var logAnalyticsWorkspaceName = 'log-${workloadName}-${environmentName}'

// Resource Group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

// Storage Account
module storage 'modules/storage.bicep' = {
  scope: resourceGroup
  name: 'storage-deployment'
  params: {
    location: location
    storageAccountName: take(storageAccountName, 24)
    tags: tags
  }
}

// Application Insights and Log Analytics
module monitoring 'modules/appinsights.bicep' = {
  scope: resourceGroup
  name: 'monitoring-deployment'
  params: {
    location: location
    appInsightsName: appInsightsName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    tags: tags
  }
}

// Function App with Flex Consumption (FC1)
module functionApp 'modules/functionapp.bicep' = {
  scope: resourceGroup
  name: 'functionapp-deployment'
  params: {
    location: location
    functionAppName: functionAppName
    storageAccountName: storage.outputs.storageAccountName
    appInsightsConnectionString: monitoring.outputs.appInsightsConnectionString
    tags: tags
  }
}

// Outputs
output resourceGroupName string = resourceGroup.name
output storageAccountName string = storage.outputs.storageAccountName
output functionAppName string = functionApp.outputs.functionAppName
output functionAppHostName string = functionApp.outputs.functionAppHostName
output mcpEndpoint string = functionApp.outputs.mcpEndpoint
output appInsightsConnectionString string = monitoring.outputs.appInsightsConnectionString
output deploymentInstructions string = '''
Next steps:
1. Deploy the Function App code: cd src && func azure functionapp publish ${functionApp.outputs.functionAppName}
2. Get the MCP system key: az functionapp keys list --resource-group ${resourceGroup.name} --name ${functionApp.outputs.functionAppName} --query systemKeys.mcp_extension --output tsv
3. Test MCP endpoint: ${functionApp.outputs.mcpEndpoint}
'''
