

resource openai1 'Microsoft.ApiManagement/service/backends@2023-05-01-preview' = {
  name: 'ai-poc-apim-sweden/openai-backend-1'
  properties: {
    description: 'Backend for OpenAI'
    type: 'single'
    protocol: 'http'
    url: 'https://ai-poc-openai-sweden.openai.azure.com/openai'
  }
}

resource openai2 'Microsoft.ApiManagement/service/backends@2023-05-01-preview' = {
  name: 'ai-poc-apim-sweden/openai-backend-2'
  properties: {
    description: 'Backend for OpenAI'
    type: 'single'
    protocol: 'http'
    url: 'https://ai-poc-openai-sweden2.openai.azure.com/openai'
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
