
$tenantID = "<tenant ID>"
$subscriptionIDs = @("<subscription ID 1>", "<subscription ID 2>")
$securityContactEmail = "<security contact email>"


# Connect to your Azure account
Connect-AzAccount -TenantId $tenantID -Subscription $subscriptionIDs[0] | Out-Null


# Configure Microsoft Defender for Cloud for each subscription
foreach ($subscriptionID in $subscriptionIDs) {
  Write-Host "Configuring subscription: $subscriptionID..."
  Set-AzContext -Subscription $subscriptionID -Tenant $tenantID | Out-Null
  # Register the Microsoft.Security resource provider
  Write-Host "Register security provider..." -NoNewline
  Register-AzResourceProvider -ProviderNamespace 'Microsoft.Security' | Out-Null
  Write-Host "...done."

  # Define the URI
  $uri = "https://management.azure.com/subscriptions/" + $subscriptionID + "/providers/Microsoft.Security/securityContacts/default?api-version=2020-01-01-preview"

  # Define the body
  $body = @{
      "properties" = @{
          "emails" = $securityContactEmail
          "notificationsByRole" = @{
              "state" = "On"
              "roles" = @("ServiceAdmin","Owner")
          }
          "alertNotifications" = @{
              "state" = "On"
              "minimalSeverity" = "Medium"
          }
          "phone" = ""
      }
  } | ConvertTo-Json -Depth 5

  # Send the PUT request
  $response = Invoke-RestMethod -Uri $uri -Method Put -Body $body -ContentType "application/json" -Headers @{Authorization="Bearer $(az account get-access-token --query accessToken -o tsv)"}

  # Output the response
  $response

  # Register resource providers needed for CAF LZ deployment
  Write-Host "Registering resource providers..." -NoNewline
  az provider register --namespace Microsoft.AlertsManagement
  az provider register --namespace Microsoft.Insights
  az provider register --namespace Microsoft.AlertsManagement
  az provider register --namespace Microsoft.OperationalInsights
  az provider register --namespace Microsoft.OperationsManagement
  az provider register --namespace Microsoft.Automation
  az provider register --namespace Microsoft.AlertsManagement
  az provider register --namespace Microsoft.Security
  az provider register --namespace Microsoft.Network
  az provider register --namespace Microsoft.EventGrid
  az provider register --namespace Microsoft.ManagedIdentity
  az provider register --namespace Microsoft.GuestConfiguration
  az provider register --namespace Microsoft.Advisor
  az provider register --namespace Microsoft.PolicyInsights
  write-host "...done."

  Write-Host "Subscription done."
}