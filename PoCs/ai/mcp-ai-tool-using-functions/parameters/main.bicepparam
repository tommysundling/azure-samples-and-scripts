using '../main.bicep'

param location = 'swedencentral'
param environmentName = 'dev'
param workloadName = 'mcphello'
param tags = {
  Environment: 'dev'
  Workload: 'mcphello'
  ManagedBy: 'Bicep'
  Purpose: 'MCP-Hello-AI-Function'
  Owner: 'YourName'
}
