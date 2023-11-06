
az login --tenant 'MngEnvMCAP160731.onmicrosoft.com'
az account set --subscription 'a4c5155b-e997-4da7-982c-bd61122015a6' # Internal Sandbox

az deployment sub create `
    --location 'swedencentral' `
    --template-file 'main.bicep' `
    --parameters '.\main.dev.bicepparam'
