# OpenAI scaling with API Management (PoC)

## Introduction

Welcome to this PoC solution where we take a look at how to work with OpenAI and API Management to provide improved redundancy and scaling.

## Objective

The main objective of this proof of concept is to demonstrate the feasibility and potential of using API Management as the frontend of multiple OpenAI instances. It aims to validate key assumptions, test functionality, and gather feedback for further development regarding primarily scaling OpenAI solutions and removing a single point of failure from the architecture.

## Solution Overview

> The proof of concept solution is designed to address a specific problem or requirement. It leverages [insert technology or framework] to provide a solution that meets the desired outcomes.

## Prerequisuites
- Bicep CLI v0.24.24
<!-- - [.NET v8](https://dotnet.microsoft.com/en-us/download/dotnet/8.0) -->

## Getting Started

To get started with the proof of concept solution, follow the steps below:

1. Create Resource Group
1. Create two OpenAI instances
1. Create APIM instance
1. OpenAI(both): Deploy model in AI Studio
    - Tokens: 1K/min
    - Dynamic Quota: Disabled
1. Verify that chat completions work through Postman
1. Download and modify the OpenAI API swagger reference file
1. APIM: Follow instructions, [Import and publish a backend API](https://learn.microsoft.com/en-us/azure/api-management/import-and-publish#import-and-publish-a-backend-api), to import API
    - OpenAPI spec: Use the modified swagger file for OpenAI
    - Products: Unlimited
1. APIM: Enable Managed Identity for APIM instance
    1. APIM: Add MI as ```Cognitive Services OpenAI User``` on both OpenAI instances
    1. APIM: Add inbound policy for the API, ```<authentication-managed-identity resource="https://cognitiveservices.azure.com" />```
1. APIM: Implement 'circuit-breaker' and 'load balancer' policies for the OpenAI API 
    1. Implement Backend for OpenAI #1 with 'circuit breaker' policy
    1. Implement Backend for OpenAI #2 with 'circuit breaker' policy
    1. Implement Backend for 'load balancer' that references above backends
    1. Use ```<set-backend-service backend-id="<load balancer backend>" />``` as Inbound policy for API
1. Create Log Analytics workspace + Application Insights for logging
1. APIM: Configure APIM to use Application Insights
    - Expand ```Advanced Options``` and enable all Frontend and Backend options
1. Ready for **demo**

&nbsp;

## Food for thought

- [Azure OpenAI Architecture Patterns and implementation steps](https://techcommunity.microsoft.com/t5/ai-azure-ai-services-blog/azure-openai-architecture-patterns-and-implementation-steps/ba-p/3979934)
- [Using Azure API Management Circuit Breaker and Load balancing with Azure OpenAI Service](https://techcommunity.microsoft.com/t5/fasttrack-for-azure/using-azure-api-management-circuit-breaker-and-load-balancing/ba-p/4041003)
- [Protect your Azure OpenAI API keys with Azure API Management](https://learn.microsoft.com/en-us/semantic-kernel/deploy/use-ai-apis-with-api-management)
- [Smart load balancing for OpenAI endpoints and Azure API Management](https://techcommunity.microsoft.com/t5/fasttrack-for-azure/smart-load-balancing-for-openai-endpoints-and-azure-api/ba-p/3991616)
- [Azure OpenAI Service REST API reference](https://learn.microsoft.com/en-us/azure/ai-services/openai/reference)
- [Planning for Resiliency with Azure OpenAI](https://techcommunity.microsoft.com/t5/healthcare-and-life-sciences/planning-for-resiliency-with-azure-openai/ba-p/4050673)

## Conclusion

Thank you for exploring our proof of concept solution. We hope this demonstration provides valuable insights and helps you make informed decisions regarding the adoption of this solution.
