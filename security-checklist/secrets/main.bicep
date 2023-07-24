param prefix string

@description('The location of the resource.')
param location string = resourceGroup().location

@description('The size of the Virtual Machine.')
param agentVMSize string = 'standard_d2s_v3'

resource myAKS 'Microsoft.ContainerService/managedClusters@2023-05-02-preview' = {
  name: '${prefix}${uniqueString(resourceGroup().id)}'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${myIdentity.id}': {}
    }
  }
  properties: {
    dnsPrefix: '${prefix}${uniqueString(resourceGroup().id)}'
    agentPoolProfiles: [
      {
        name: 'agentpool'
        osDiskSizeGB: 0
        count: 1
        vmSize: agentVMSize
        osType: 'Linux'
        mode: 'System'
      }
    ]
    securityProfile: {
      azureKeyVaultKms: {
        enabled: true
        keyId: myKey.properties.keyUriWithVersion
      }
    }
  }
}

resource myIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${prefix}${uniqueString(resourceGroup().id)}'
  location: location
}

resource myKeyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: '${prefix}${uniqueString(resourceGroup().id)}'
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: myIdentity.properties.principalId
        permissions: {
          keys: [
            'encrypt'
            'decrypt'
          ]
        }
      }
    ]
  }
}

resource myKey 'Microsoft.KeyVault/vaults/keys@2023-02-01' = {
  parent: myKeyVault
  name: '${prefix}${uniqueString(resourceGroup().id)}'
  properties: {
    kty: 'RSA'
    keySize: 2048
    keyOps: [
      'encrypt'
      'decrypt'
    ]
  }
}

output clusterName string = myAKS.name
output keyId string = myKey.properties.keyUriWithVersion
