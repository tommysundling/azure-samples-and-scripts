### Azure PowerShell
### Written by Tommy Sundling


### CREATE SERVICE PRINCIPAL FOR POSTMAN LOGIN

az login
# Create the Service Principal Postman will use
az ad sp create-for-rbac -n PostmanCred
<# Sample output
{
  "appId": "<App ID GUID>",
  "displayName": "PostmanCred",
  "password": "<password>",
  "tenant": "<tenant GUID>"
}
#>

### ASSIGN APPROPRIATE RBAC TO THE SERVICE PRINCIPAL
