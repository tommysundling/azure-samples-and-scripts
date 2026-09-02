$ErrorActionPreference = 'Stop'

# ----- Configuration -----
$tenantId        = 'a4684b4e-bcdf-43c0-abee-60a7e80aa557'
$subscriptionId  = 'f21c6cb3-19d9-498c-abe6-ab3513b5f513'
$location        = 'SwedenCentral'
$resourceGroup   = 'poc-vm-basic-windows-rg'    # must match resourceGroupName in main.bicepparam
$kvResourceGroup = $resourceGroup               # KV lives in the same RG as the workload
$kvName          = 'kv-vmpoc-tosundli'          # fixed Key Vault name (must be globally unique, 3-24 chars)
$secretName      = 'vm-admin-password'

# Password file lives next to this script (do NOT commit it)
$pwdFile = Join-Path $PSScriptRoot 'admin-password.txt'

# 1. Ensure we are logged in to the correct tenant/subscription (no prompt if already valid)
$currentUserId = az account show --query "{tid:tenantId, sid:id}" -o json 2>$null | ConvertFrom-Json
if (-not $currentUserId -or $currentUserId.tid -ne $tenantId -or $currentUserId.sid -ne $subscriptionId) {
    Write-Host "Signing in to tenant $tenantId ..."
    az login --tenant $tenantId --scope "https://graph.microsoft.com//.default" --only-show-errors | Out-Null
    az account set --subscription $subscriptionId
}

# 2. Auto-populate the object ID of the signed-in user (requires Graph token; refresh if MFA-required)
$userObjectId = az ad signed-in-user show --query id -o tsv 2>$null
if ([string]::IsNullOrWhiteSpace($userObjectId)) {
    Write-Host "Refreshing Microsoft Graph token (MFA may be required) ..."
    az login --tenant $tenantId --scope "https://graph.microsoft.com//.default" --only-show-errors | Out-Null
    $userObjectId = az ad signed-in-user show --query id -o tsv
}
if ([string]::IsNullOrWhiteSpace($userObjectId)) {
    throw "Could not resolve signed-in user's objectId. Aborting."
}
Write-Host "Deploying as user objectId: $userObjectId"

# 3. Generate or reuse local admin password
if (Test-Path $pwdFile) {
    $adminPassword = Get-Content $pwdFile -Raw
    Write-Host "Reusing admin password from $pwdFile"
} else {
    # GUID-based password: uppercase + lowercase + digits + hyphens, plus a symbol to satisfy
    # Windows VM complexity rules (needs 3 of 4: upper, lower, digit, non-alphanumeric).
    $guid = [guid]::NewGuid().ToString()
    $adminPassword = ($guid.Substring(0, 18).ToUpper()) + $guid.Substring(18) + '!aZ9'
    Set-Content -Path $pwdFile -Value $adminPassword -NoNewline
    Write-Host "Generated new admin password and saved it to $pwdFile"
}

# 4. Ensure the resource group exists
az group create --name $resourceGroup --location $location --only-show-errors | Out-Null

# 5. Deploy the Key Vault (and password secret) via Bicep — separate step from main template
Write-Host "Deploying Key Vault '$kvName' (and secret '$secretName') via Bicep ..."
az deployment group create `
    --resource-group $kvResourceGroup `
    --name 'keyVaultDeployment' `
    --template-file .\modules\keyvault.bicep `
    --parameters keyVaultName=$kvName `
                 deployerObjectId=$userObjectId `
                 location=$location `
                 secretName=$secretName `
                 secretValue=$adminPassword `
    --only-show-errors | Out-Null

# 6. Deploy main template — bicepparam pulls adminPassword via az.getSecret()
$env:SUBSCRIPTION_ID   = $subscriptionId
$env:KV_NAME           = $kvName
$env:KV_RESOURCE_GROUP = $kvResourceGroup

az deployment sub create `
    --template-file .\main.bicep `
    --location $location `
    --parameters .\parameters\main.bicepparam

