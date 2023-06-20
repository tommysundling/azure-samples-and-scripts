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