<#
.SYNOPSIS
    Deploys the Azure Function MCP Hello AI solution to Azure.

.DESCRIPTION
    This script automates the deployment of:
    1. Azure infrastructure (Storage, Function App, Application Insights)
    2. .NET Function App code with MCP binding
    3. Retrieves MCP system key for client configuration

.PARAMETER SubscriptionId
    The Azure subscription ID to deploy to

.PARAMETER Location
    The Azure region for deployment (default: swedencentral)

.PARAMETER EnvironmentName
    The environment name (dev, test, prod) (default: dev)

.PARAMETER SkipInfrastructure
    Skip infrastructure deployment and only deploy function code

.EXAMPLE
    .\deploy.ps1 -SubscriptionId "your-subscription-id"

.EXAMPLE
    .\deploy.ps1 -SubscriptionId "your-subscription-id" -EnvironmentName "prod" -Location "westeurope"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory = $false)]
    [string]$Location = "swedencentral",
    
    [Parameter(Mandatory = $false)]
    [ValidateSet("dev", "test", "prod")]
    [string]$EnvironmentName = "dev",
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipInfrastructure
)

$ErrorActionPreference = "Stop"

# Color output functions
function Write-Info { param($Message) Write-Host "ℹ️  $Message" -ForegroundColor Cyan }
function Write-Success { param($Message) Write-Host "✅ $Message" -ForegroundColor Green }
function Write-Warning { param($Message) Write-Host "⚠️  $Message" -ForegroundColor Yellow }
function Write-Error { param($Message) Write-Host "❌ $Message" -ForegroundColor Red }

Write-Info "Starting deployment of MCP Hello AI Function..."

# Set Azure subscription context
Write-Info "Setting Azure subscription context..."
az account set --subscription $SubscriptionId
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to set subscription context"
    exit 1
}
Write-Success "Subscription set: $SubscriptionId"

# Deploy infrastructure
if (-not $SkipInfrastructure) {
    Write-Info "Deploying Azure infrastructure with Bicep..."
    
    $deploymentName = "mcp-hello-deployment-$(Get-Date -Format 'yyyyMMddHHmmss')"
    
    az deployment sub create `
        --name $deploymentName `
        --location $Location `
        --template-file "main.bicep" `
        --parameters "parameters/main.bicepparam" `
        --parameters environmentName=$EnvironmentName `
        --parameters location=$Location `
        --only-show-errors
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Infrastructure deployment failed"
        exit 1
    }
    
    Write-Success "Infrastructure deployed successfully"
    
    # Get deployment outputs
    Write-Info "Retrieving deployment outputs..."
    $outputs = az deployment sub show `
        --name $deploymentName `
        --query properties.outputs `
        --output json | ConvertFrom-Json
    
    $resourceGroupName = $outputs.resourceGroupName.value
    $functionAppName = $outputs.functionAppName.value
    $mcpEndpoint = $outputs.mcpEndpoint.value
    
    Write-Success "Resource Group: $resourceGroupName"
    Write-Success "Function App: $functionAppName"
    Write-Success "MCP Endpoint: $mcpEndpoint"
} else {
    Write-Warning "Skipping infrastructure deployment"
    
    # Manual input required
    $resourceGroupName = Read-Host "Enter Resource Group Name"
    $functionAppName = Read-Host "Enter Function App Name"
}

# Build and publish Function App
Write-Info "Building .NET Function App..."
Push-Location "src"

try {
    # Restore dependencies
    Write-Info "Restoring NuGet packages..."
    dotnet restore
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to restore NuGet packages"
    }
    
    # Build the project
    Write-Info "Building project..."
    dotnet build --configuration Release
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to build project"
    }
    
    Write-Success "Build completed successfully"
    
    # Publish to Azure
    Write-Info "Publishing Function App to Azure..."
    Write-Warning "This may take several minutes..."
    
    func azure functionapp publish $functionAppName --dotnet
    
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to publish Function App"
    }
    
    Write-Success "Function App published successfully"
} catch {
    Write-Error "Deployment failed: $_"
    Pop-Location
    exit 1
} finally {
    Pop-Location
}

# Retrieve MCP system key
Write-Info "Retrieving MCP system key..."
$mcpSystemKey = az functionapp keys list `
    --resource-group $resourceGroupName `
    --name $functionAppName `
    --query "systemKeys.mcp_extension" `
    --output tsv

if ([string]::IsNullOrEmpty($mcpSystemKey)) {
    Write-Warning "Could not retrieve MCP system key automatically"
    Write-Info "Run this command manually:"
    Write-Host "  az functionapp keys list --resource-group $resourceGroupName --name $functionAppName --query systemKeys.mcp_extension --output tsv" -ForegroundColor Gray
} else {
    Write-Success "MCP System Key retrieved"
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    Write-Host "🎉 Deployment Complete!" -ForegroundColor Green
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "📋 Configuration Details:" -ForegroundColor Cyan
    Write-Host "  Function App:  $functionAppName" -ForegroundColor White
    Write-Host "  MCP Endpoint:  https://$($functionAppName).azurewebsites.net/runtime/webhooks/mcp" -ForegroundColor White
    Write-Host "  System Key:    $mcpSystemKey" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "🔧 Next Steps:" -ForegroundColor Cyan
    Write-Host "  1. Update mcp.json with the endpoint and system key" -ForegroundColor White
    Write-Host "  2. Test with GitHub Copilot or your MCP client" -ForegroundColor White
    Write-Host "  3. Monitor logs in Application Insights" -ForegroundColor White
    Write-Host ""
    Write-Host "📖 See README.md for testing instructions" -ForegroundColor Gray
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
}
