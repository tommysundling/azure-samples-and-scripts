
az login --tenant 'MngEnvMCAP889061.onmicrosoft.com'
az account set --subscription 'b2e3574b-9fc4-4047-b92e-c4b21f01dc88' # Internal Sandbox

az deployment group create `
    --resource-group 'poc-vm-basic-windows' `
    --template-file 'main.bicep' `
    --parameters '.\main.bicepparam'
