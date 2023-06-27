param prefix string

param location string

param skuName string

resource myAcr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: '${prefix}${uniqueString(resourceGroup().id)}'
  location: location
  sku: {
    name: skuName
  }
  properties: {
    adminUserEnabled: true
    anonymousPullEnabled: true
  }
}

output acrLoginServer string = myAcr.properties.loginServer
