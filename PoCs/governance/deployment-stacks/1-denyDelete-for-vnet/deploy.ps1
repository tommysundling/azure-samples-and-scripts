
az login --tenant "ebc1ce4a-bb8c-4db4-b38b-f14f900a45ff"

# Creates a Deployment Stack at the Subscription scope for managing a VNet
az stack sub create `
  --name demoStack-sub `
  --location 'swedencentral' `
  --template-file './main.bicep' `
  --action-on-unmanage 'detachAll' `
  --deny-settings-mode 'denyDelete' `
  --parameters `
    'rgName=demo-rg'


# Creates a Deploment Stack at the Management Group scope for managing a VNet
az stack mg create `
--name demoStack-mg-ikea `
--management-group-id 'ebc1ce4a-bb8c-4db4-b38b-f14f900a45ff' `
--deployment-subscription 'b2e3574b-9fc4-4047-b92e-c4b21f01dc88' `
--location 'swedencentral' `
--template-file './main.bicep' `
--action-on-unmanage 'detachAll' `
--deny-settings-mode 'denyDelete' `
--parameters `
  'rgName=demo-rg'