


resource circuitBreakerBackend 'Microsoft.ApiManagement/service/backends@2023-03-01-preview' = {
  name: 'aoai-backend-1'
  properties: {
    url: 'https://ai-poc-openai-sweden.openai.azure.com/'
    protocol: 'http'
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
