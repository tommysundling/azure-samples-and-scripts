
# az login --tenant ebc1ce4a-bb8c-4db4-b38b-f14f900a45ff
az account set --subscription b2e3574b-9fc4-4047-b92e-c4b21f01dc88

az deployment sub create --template-file .\main.bicep --location SwedenCentral --parameters deployVm=true