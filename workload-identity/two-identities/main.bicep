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

resource myIdentity1 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${prefix}01'
  location: location
}

resource myIdentity2 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${prefix}02'
  location: location
}

resource myFederatedIdentityCredentials1 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-01-31' = {
  name: '${prefix}01'
  parent: myIdentity1
  properties: {
    audiences: [
      'api://AzureADTokenExchange'
    ]
    issuer: myAKS.properties.oidcIssuerProfile.issuerURL
    subject: 'system:serviceaccount:${serviceAccountNamespace}:${serviceAccountName}'
  }
}

resource myFederatedIdentityCredentials2 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-01-31' = {
  name: '${prefix}02'
  parent: myIdentity2
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
        objectId: myIdentity1.properties.principalId
        permissions: {
          secrets: [
            'get'
          ]
        }
      }
      {
        tenantId: subscription().tenantId
        objectId: myIdentity2.properties.principalId
        permissions: {
          secrets: [
            'set'
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
output primaryUserAssignedClientId string = myIdentity1.properties.clientId
output secondaryUserAssignedClientId string = myIdentity2.properties.clientId
output serviceAccountNamespace string = serviceAccountNamespace
output serviceAccountName string = serviceAccountName
output keyVaultName string = myKeyVault.name
output keyVaultUri string = myKeyVault.properties.vaultUri
output secretName string = mySecret.name
