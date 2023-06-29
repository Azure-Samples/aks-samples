param keyVaultName string
param keyName string

resource existedKeyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

resource myKey 'Microsoft.KeyVault/vaults/keys@2022-07-01' = {
  name: keyName
  parent: existedKeyVault
  properties: {
      keySize: 4096
      kty: 'RSA'
  }
}
output keyUri string = myKey.properties.keyUri
output keyUriWithVersion string = myKey.properties.keyUriWithVersion