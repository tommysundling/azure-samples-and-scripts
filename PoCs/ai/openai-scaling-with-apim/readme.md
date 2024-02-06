# OpenAI scaling with API Management (PoC)

## Introduction

Welcome to this PoC solution where we take a look at how to work with OpenAI and API Management to provide improved redundancy and scaling.

## Objective

The main objective of this proof of concept is to demonstrate the feasibility and potential of using API Management as the frontend of multiple OpenAI instances. It aims to validate key assumptions, test functionality, and gather feedback for further development regarding primarily scaling OpenAI solutions and removing a single point of failure from the architecture.

## Solution Overview

> The proof of concept solution is designed to address a specific problem or requirement. It leverages [insert technology or framework] to provide a solution that meets the desired outcomes.

## Prerequisuites
N/A
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
1. APIM: Create a named value for the OpenAI API Key [Use named values in Azure API Management policies](https://learn.microsoft.com/en-us/azure/api-management/api-management-howto-properties?tabs=azure-portal)
1. APIM: Add Inbound policy "Set Header" for API, with name "openai-key", the value referencing the named value above

## Food for thought

- [Azure OpenAI Architecture Patterns and implementation steps](https://techcommunity.microsoft.com/t5/ai-azure-ai-services-blog/azure-openai-architecture-patterns-and-implementation-steps/ba-p/3979934)
- [Using Azure API Management Circuit Breaker and Load balancing with Azure OpenAI Service](https://techcommunity.microsoft.com/t5/fasttrack-for-azure/using-azure-api-management-circuit-breaker-and-load-balancing/ba-p/4041003)
- [Protect your Azure OpenAI API keys with Azure API Management](https://learn.microsoft.com/en-us/semantic-kernel/deploy/use-ai-apis-with-api-management)
- [Azure OpenAI Service REST API reference](https://learn.microsoft.com/en-us/azure/ai-services/openai/reference)

## Conclusion

Thank you for exploring our proof of concept solution. We hope this demonstration provides valuable insights and helps you make informed decisions regarding the adoption of this solution.
