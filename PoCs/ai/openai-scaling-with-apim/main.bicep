
param location string = 'swedencentral'


resource openai1 'Microsoft.ApiManagement/service/backends@2023-05-01-preview' = {
  name: 'ai-poc-apim-sweden/openai-backend-1'
  properties: {
    description: 'Backend for OpenAI'
    type: 'single'
    protocol: 'http'
    url: 'https://ai-poc-openai-sweden.openai.azure.com/openai'
    circuitBreaker: {
      rules: [
        {
          failureCondition: {
            count: 1
            errorReasons: [
              'Server errors'
            ]
            interval: 'PT10S'
            statusCodeRanges: [
              {
                min: 429
                max: 429
              }
            ]
          }
          name: 'myBreakerRule'
          tripDuration: 'PT10S'
        }
      ]
    }
  }
}

resource openai2 'Microsoft.ApiManagement/service/backends@2023-05-01-preview' = {
  name: 'ai-poc-apim-sweden/openai-backend-2'
  properties: {
    description: 'Backend for OpenAI'
    type: 'single'
    protocol: 'http'
    url: 'https://ai-poc-openai-sweden2.openai.azure.com/openai'
    circuitBreaker: {
      rules: [
        {
          failureCondition: {
            count: 1
            errorReasons: [
              'Server errors'
            ]
            interval: 'PT10S'
            statusCodeRanges: [
              {
                min: 429
                max: 429
              }
            ]
          }
          name: 'myBreakerRule'
          tripDuration: 'PT10S'
        }
      ]
    }
  }
}


resource loadBalancerPool 'Microsoft.ApiManagement/service/backends@2023-05-01-preview' = {
  name: 'ai-poc-apim-sweden/myBackendPool'
  properties: {
    description: 'Load balancer for multiple backends'
    type: 'Pool'
    protocol: 'http'
    url: 'https://example.com'
    pool: {
      services: [
        {
          id: '/backends/openai-backend-1'
        }
        {
          id: '/backends/openai-backend-2'
        }
      ]
    }
  }
  dependsOn: [
    openai1
    openai2
  ]
}


resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: 'ai-poc-logworkspace-sweden'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: 'ai-poc-appinsights-sweden'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
  }
}
