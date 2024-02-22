### Azure PowerShell
### Written by Tommy Sundling


### GET AVAILABLE PROVIDERS AND RESOURCETYPES

Login-AzAccount
# Get available ResourceProviders for Sweden Central
Get-AzResourceProvider -ListAvailable | Where-Object { $_.Locations -contains 'Sweden Central' } | Select-Object -Property ProviderNamespace, ResourceTypes
# Get available ResourceTypes for Sweden Central
Get-AzResourceProvider -ListAvailable | 
    Where-Object { $_.Locations -contains 'Sweden Central' } | 
    Select-Object -Property ProviderNamespace -ExpandProperty ResourceTypes | 
    Format-Table -Property ProviderNamespace, ResourceTypeName


### DO WORK IN EACH SUBSCRIPTION

# Get list of all subscriptions in a tenant
$tenantId = "<tenant ID>"
$subscriptions = Get-AzSubscription -TenantId $tenantId | Select-Object -Property Name, Id

# Do work in each subscription
foreach ($subscription in $subscriptions) {
    # Set the subscription context
    Set-AzContext -Subscription $subscription.Id -TenantId $tenantId | Out-Null
    Write-Host "Working in subscription: $($subscription.Name)"
    # Do work here
}