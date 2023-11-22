
# NOTE: The script below deploys the role definitions into a Subscription. Other scopes are possible

$tenantId = "<tenantid>"
$subscriptionId = "<subscriptionid>"
# Specify the directory containing the role definition JSON files
$directoryPath = "<directorypath>"


az login --tenant $tenantId

# Set the Azure subscription
az account set --subscription $subscriptionId


$virtualMachineOperator = $directoryPath + "\virtual machine contributor.json"
# Create the role definition
az role definition create --role-definition $virtualMachineOperator
# Update existing role definition
az role definition update --role-definition $virtualMachineOperator

$backupOperator = $directoryPath + "\backup operator.json"
# Create the role definition
az role definition create --role-definition $backupOperator
# Update existing role definition
az role definition update --role-definition $backupOperator
