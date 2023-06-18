#!/bin/bash

set -e
set -x

prefix="$1"
resourceGroupName="$prefix"
deploymentName="$prefix"

az group create --name $resourceGroupName --location "westus2"

az deployment group create \
  --name $deploymentName \
  --resource-group $resourceGroupName \
  --template-file main.bicep \
  --parameters prefix=$prefix

clusterName=$(az deployment group show \
  -g $resourceGroupName  \
  -n $deploymentName \
  --query properties.outputs.clusterName.value \
  -o tsv)

userAssignedClientId=$(az deployment group show \
  -g $resourceGroupName  \
  -n $deploymentName \
  --query properties.outputs.userAssignedClientId.value \
  -o tsv)

serviceAccountNamespace=$(az deployment group show \
  -g $resourceGroupName  \
  -n $deploymentName \
  --query properties.outputs.serviceAccountNamespace.value \
  -o tsv)

serviceAccountName=$(az deployment group show \
  -g $resourceGroupName  \
  -n $deploymentName \
  --query properties.outputs.serviceAccountName.value \
  -o tsv)

keyVaultUri=$(az deployment group show \
  -g $resourceGroupName  \
  -n $deploymentName \
  --query properties.outputs.keyVaultUri.value \
  -o tsv)

secretName=$(az deployment group show \
  -g $resourceGroupName  \
  -n $deploymentName \
  --query properties.outputs.secretName.value \
  -o tsv)

az aks get-credentials \
  --admin \
  --name $clusterName \
  --resource-group $resourceGroupName \
  --only-show-errors

command="cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    azure.workload.identity/client-id: "${userAssignedClientId}"
  name: "${serviceAccountName}"
  namespace: "${serviceAccountNamespace}"
EOF"

az aks command invoke \
  --name $clusterName \
  --resource-group $resourceGroupName \
  --command "$command"

command="cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: quick-start
  namespace: ${serviceAccountNamespace}
  labels:
    azure.workload.identity/use: \"true\"
spec:
  serviceAccountName: ${serviceAccountName}
  containers:
    - image: ghcr.io/azure/azure-workload-identity/msal-go
      name: oidc
      env:
      - name: KEYVAULT_URL
        value: ${keyVaultUri}
      - name: SECRET_NAME
        value: ${secretName}
  nodeSelector:
    kubernetes.io/os: linux
EOF"

az aks command invoke \
  --name $clusterName \
  --resource-group $resourceGroupName \
  --command "$command"

az aks command invoke \
  --name $clusterName \
  --resource-group $resourceGroupName \
  --command "kubectl logs quick-start -n ${serviceAccountNamespace}"