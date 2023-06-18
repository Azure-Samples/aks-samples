param prefix string

@description('The location of the resource.')
param location string = resourceGroup().location

@description('The size of the Virtual Machine.')
param agentVMSize string = 'standard_d2s_v3'

@description('The name of the service account namespace.')
param serviceAccountNamespace string = 'default'

@description('The name of the service account.')
param serviceAccountName string = 'workload-identity-sa'

resource myAKS 'Microsoft.ContainerService/managedClusters@2023-03-02-preview' = {
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
    oidcIssuerProfile: {
      enabled: true
    }
    securityProfile: {
      workloadIdentity: {
        enabled: true
      }
    }
  }
}

resource myIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${prefix}01'
  location: location
}

resource myFederatedIdentityCredentials 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-01-31' = {
  name: '${prefix}01'
  parent: myIdentity
  properties: {
    audiences: [
      'api://AzureADTokenExchange'
    ]
    issuer: myAKS.properties.oidcIssuerProfile.issuerURL
    subject: 'system:serviceaccount:${serviceAccountNamespace}:${serviceAccountName}'
  }
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
          secrets: [
            'get'
          ]
        }
      }
    ]
  }
}

resource mySecret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: '${prefix}${uniqueString(resourceGroup().id)}'
  parent: myKeyVault
  properties: {
    value: 'Hello!'
  }
}

output clusterName string = myAKS.name
output userAssignedClientId string = myIdentity.properties.clientId
output serviceAccountNamespace string = serviceAccountNamespace
output serviceAccountName string = serviceAccountName
output keyVaultName string = myKeyVault.name
output keyVaultUri string = myKeyVault.properties.vaultUri
output secretName string = mySecret.name
