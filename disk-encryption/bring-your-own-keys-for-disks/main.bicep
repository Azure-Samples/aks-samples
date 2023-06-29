param prefix string

@description('The size of the Virtual Machine.')
param agentVMSize string = 'standard_d2s_v3'

@description('The location of the resource.')
param location string = resourceGroup().location

var resourceName = '${prefix}${uniqueString(resourceGroup().id)}'

module akv 'akv.bicep' = {
  name: 'akv'
  params: {
    keyVaultName: resourceName
    location: location
  }
}

module key './akv/key.bicep' = {
  name: 'key'
  params: {
    keyVaultName: akv.outputs.akvName
    keyName: 'diskkey'
  }
}

resource diskEncryptionSets 'Microsoft.Compute/diskEncryptionSets@2022-07-02' = {
  name: resourceName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    activeKey: {
      keyUrl: key.outputs.keyUriWithVersion
      sourceVault: {
        id: akv.outputs.akvId
      }
    }
  }
}

module diskSetIdentityAccessKeyVault './akv/accesspolicy.bicep' = {
  name: 'diskSetIdentityAccessKeyVault'
  params: {
    keyVaultName: akv.outputs.akvName
    objectId: diskEncryptionSets.identity.principalId
    permissions: {
      keys: [
        'get', 'wrapKey', 'unwrapKey'
      ]
    }
  }
}

resource myAKS 'Microsoft.ContainerService/managedClusters@2023-03-01' = {
  name: '${prefix}${uniqueString(resourceGroup().id)}'
  location: location
  identity: {
    type: 'SystemAssigned'
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
    diskEncryptionSetID: diskEncryptionSets.id
  }
}

output clusterName string = myAKS.name
output diskEncryptionSetName string = diskEncryptionSets.name
