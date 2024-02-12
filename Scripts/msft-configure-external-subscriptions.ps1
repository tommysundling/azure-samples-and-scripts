
$tenantID = "<tenant ID>"
$subscriptionIDs = @("<subscription ID 1>", "<subscription ID 2>")



# Connect to your Azure account
Connect-AzAccount --tenantid $tenantID

# Set your default subscription
Get-AzSubscription
Set-AzContext -Subscription "<subscription ID>"

# Register the Microsoft.Security resource provider
Register-AzResourceProvider -ProviderNamespace 'Microsoft.Security'

# Define the security contact details
Set-AzSecurityContact `
  -Name "SecurityContact1" `
  -Email "security@yourdomain.com" `
  -Phone "555-1234" `
  -AlertAdmin `
  -NotifyOnAlert