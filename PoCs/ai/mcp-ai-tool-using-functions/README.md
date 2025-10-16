# Azure Function with Model Context Protocol (MCP) - Hello AI

A simple Azure Function implementation using the **Model Context Protocol (MCP) binding** that responds with "Hello AI" formatted as JSON when called by an AI agent.

## 🎯 Overview

This project demonstrates how to:
- Create an Azure Function with MCP tool trigger
- Deploy a remote MCP server using Azure Functions
- Connect AI agents (like GitHub Copilot) to your custom MCP server
- Use Flex Consumption (FC1) plan for serverless, cost-effective hosting

## 📋 Prerequisites

- [.NET 8.0 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)
- [Azure Functions Core Tools](https://docs.microsoft.com/azure/azure-functions/functions-run-local) v4.0.7030 or later
- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)
- An Azure subscription
- [PowerShell 7+](https://github.com/PowerShell/PowerShell)
- (Optional) [GitHub Copilot](https://github.com/features/copilot) for testing

## 🏗️ Architecture

```
┌─────────────────┐
│   AI Agent      │
│ (GitHub Copilot)│
└────────┬────────┘
         │ MCP Protocol
         │ (HTTPS)
         ▼
┌─────────────────┐
│ Azure Function  │
│  (Flex FC1)     │◄─────┐
├─────────────────┤      │
│  HelloTool      │      │ Identity-based
│  MCP Binding    │      │ Connection
└────────┬────────┘      │
         │               │
    ┌────▼───────────────▼────┐
    │  Storage Account         │
    │  - Deployment packages   │
    │  - Queue for MCP (SSE)   │
    └──────────────────────────┘
         │
         ▼
    ┌────────────────────┐
    │ Application        │
    │ Insights           │
    └────────────────────┘
```

## 🚀 Quick Start

### 1. Local Development

```powershell
# Navigate to source directory
cd src

# Restore dependencies
dotnet restore

# Build the project
dotnet build

# Run locally
func start
```

The local MCP endpoint will be available at:
```
http://localhost:7071/runtime/webhooks/mcp
```

### 2. Deploy to Azure

```powershell
# Deploy infrastructure and code
.\deploy.ps1 -SubscriptionId "your-subscription-id"

# Or deploy to a specific region and environment
.\deploy.ps1 -SubscriptionId "your-subscription-id" -Location "westeurope" -EnvironmentName "prod"
```

The deployment script will:
1. ✅ Deploy Azure infrastructure (Storage, Function App, Application Insights)
2. ✅ Build the .NET project
3. ✅ Publish the Function App code
4. ✅ Retrieve the MCP system key for authentication

## 🔧 Configuration

### Azure Resources Created

| Resource Type | Naming Convention | Purpose |
|--------------|-------------------|---------|
| Resource Group | `rg-mcphello-{env}-{location}` | Container for all resources |
| Storage Account | `stmcphello{env}{unique}` | Function storage and deployment packages |
| Function App | `func-mcphello-{env}-{unique}` | Hosts the MCP server |
| Application Insights | `appi-mcphello-{env}` | Monitoring and diagnostics |
| Log Analytics | `log-mcphello-{env}` | Log storage and analytics |

### Environment Variables

The Function App is configured with:
- `AzureWebJobsStorage__accountName`: Storage account (identity-based)
- `APPLICATIONINSIGHTS_CONNECTION_STRING`: Application Insights connection
- `FUNCTIONS_EXTENSION_VERSION`: `~4`
- `FUNCTIONS_WORKER_RUNTIME`: `dotnet-isolated`

## 🧪 Testing the MCP Server

### Using GitHub Copilot in VS Code

1. **Create or update your `mcp.json` configuration:**

```json
{
    "inputs": [
        {
            "type": "promptString",
            "id": "functions-mcp-extension-system-key",
            "description": "Azure Functions MCP Extension System Key",
            "password": true
        },
        {
            "type": "promptString",
            "id": "functionapp-host",
            "description": "The host domain of the function app."
        }
    ],
    "servers": {
        "local-hello-mcp": {
            "type": "http",
            "url": "http://localhost:7071/runtime/webhooks/mcp"
        },
        "azure-hello-mcp": {
            "type": "http",
            "url": "https://${input:functionapp-host}/runtime/webhooks/mcp",
            "headers": {
                "x-functions-key": "${input:functions-mcp-extension-system-key}"
            }
        }
    }
}
```

2. **Reload VS Code** and enter the values when prompted:
   - Function App Host: `func-mcphello-dev-xxxxx.azurewebsites.net`
   - System Key: (from deployment output)

3. **Test in GitHub Copilot Chat:**
```
@azure-hello-mcp Can you call the HelloTool?
```

Expected response:
```json
{
  "message": "Hello AI",
  "timestamp": "2025-10-16T12:34:56.789Z",
  "toolName": "HelloTool",
  "requestId": "abc-123-def"
}
```

### Using cURL (Local)

```powershell
curl http://localhost:7071/runtime/webhooks/mcp
```

### Using cURL (Azure)

```powershell
$systemKey = az functionapp keys list `
    --resource-group "rg-mcphello-dev-swedencentral" `
    --name "func-mcphello-dev-xxxxx" `
    --query "systemKeys.mcp_extension" `
    --output tsv

curl -H "x-functions-key: $systemKey" `
    https://func-mcphello-dev-xxxxx.azurewebsites.net/runtime/webhooks/mcp
```

## 📁 Project Structure

```
azure-function-mcp-hello/
├── src/
│   ├── HelloTool.cs              # MCP tool function
│   ├── Program.cs                # Function app entry point
│   ├── McpHelloFunction.csproj   # .NET project file
│   ├── host.json                 # MCP server configuration
│   ├── local.settings.json       # Local development settings
│   └── .gitignore
├── modules/
│   ├── storage.bicep             # Storage Account module
│   ├── appinsights.bicep         # Application Insights module
│   └── functionapp.bicep         # Function App (FC1) module
├── parameters/
│   └── main.bicepparam           # Environment parameters
├── main.bicep                    # Main infrastructure template
├── deploy.ps1                    # Deployment automation script
├── mcp.json                      # MCP client configuration
└── README.md                     # This file
```

## 🔐 Security Considerations

- ✅ **HTTPS only** enforced
- ✅ **Managed Identity** for storage access (no connection strings)
- ✅ **MCP system key** required for remote access
- ✅ **TLS 1.2 minimum** enforced
- ✅ **Application Insights** for monitoring and audit logging
- ⚠️ Consider enabling **VNET integration** or **Private Endpoints** for production

## 💰 Cost Considerations

Using **Flex Consumption (FC1)** plan:
- **Free tier**: 1M requests/month + 400,000 GB-s
- **Pay-per-use**: Only charged for actual execution
- **Auto-scaling**: 0 to 100 instances
- **Ideal for**: Dev/test and low-volume production workloads

## 🔍 Monitoring

View logs and metrics in Azure Portal:
1. Navigate to your Function App
2. Select **Application Insights**
3. View:
   - Live Metrics
   - Transaction Search
   - Failures and Performance

Or query logs with KQL:
```kql
traces
| where message contains "HelloTool"
| order by timestamp desc
| take 50
```

## 📚 Learn More

- [Azure Functions MCP Binding Documentation](https://learn.microsoft.com/azure/azure-functions/functions-bindings-mcp?pivots=programming-language-csharp)
- [Model Context Protocol (MCP) Overview](https://modelcontextprotocol.io/)
- [GitHub Copilot MCP Integration](https://code.visualstudio.com/docs/copilot/customization/mcp-servers)
- [Azure Functions Flex Consumption Plan](https://learn.microsoft.com/azure/azure-functions/flex-consumption-plan)

## 🤝 Contributing

Feel free to enhance this sample:
- Add more sophisticated MCP tools
- Implement stateful execution
- Add authentication/authorization
- Integrate with Azure services (Cosmos DB, OpenAI, etc.)

## 📄 License

This sample is provided as-is under the MIT License.
