
az login --tenant "ebc1ce4a-bb8c-4db4-b38b-f14f900a45ff"


az stack sub create `
  --name demoStack `
  --location 'swedencentral' `
  --template-file './main.bicep' `
  --action-on-unmanage 'detachAll' `
  --deny-settings-mode 'denyDelete'
