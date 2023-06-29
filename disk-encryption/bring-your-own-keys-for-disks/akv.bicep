param keyVaultName string
param location string

var tenantId = subscription().tenantId

resource myKeyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
        family: 'A'
        name: 'standard'
    }
    accessPolicies: [
    ]
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enableSoftDelete: false
    enablePurgeProtection: true
    tenantId: tenantId
  }
}

output akvName string = myKeyVault.name
output akvId string = myKeyVault.id
output akvUri string = endsWith(myKeyVault.properties.vaultUri,'/') ? substring(myKeyVault.properties.vaultUri,0,length(myKeyVault.properties.vaultUri)-1) : myKeyVault.properties.vaultUri
