param keyVaultName string
param objectId string
param permissions object

var tenantId = subscription().tenantId

resource existedKeyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

resource myAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
  name: 'add'
  parent: existedKeyVault
  properties: {
    accessPolicies: [
      {
        objectId: objectId
        permissions: permissions
        tenantId: tenantId
      }
    ]
  }
}