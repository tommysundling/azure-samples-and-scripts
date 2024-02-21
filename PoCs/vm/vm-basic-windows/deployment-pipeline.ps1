
# az login --tenant b5151064-651c-42f2-83ae-f5e0071efbbc
az account set --subscription eb9b1426-0438-4693-99c1-129d1e5f09df

az deployment sub create --template-file .\main.bicep --location SwedenCentral