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

primaryUserAssignedClientId=$(az deployment group show \
  -g $resourceGroupName  \
  -n $deploymentName \
  --query properties.outputs.primaryUserAssignedClientId.value \
  -o tsv)

secondaryUserAssignedClientId=$(az deployment group show \
  -g $resourceGroupName  \
  -n $deploymentName \
  --query properties.outputs.secondaryUserAssignedClientId.value \
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

acrLoginServer=$(az deployment group show \
  -g $resourceGroupName  \
  -n $deploymentName \
  --query properties.outputs.acrLoginServer.value \
  -o tsv)

az acr login -n ${acrLoginServer}

pushd msal-go
  REGISTRY="${acrLoginServer}/azure/azure-workload-identity" make all
popd

az aks get-credentials \
  --admin \
  --name $clusterName \
  --resource-group $resourceGroupName \
  --only-show-errors

cat <<EOF > workload-identity.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    azure.workload.identity/client-id: "${primaryUserAssignedClientId}"
  name: "${serviceAccountName}"
  namespace: "${serviceAccountNamespace}"
---
apiVersion: v1
kind: Pod
metadata:
  name: quick-start
  namespace: ${serviceAccountNamespace}
  labels:
    azure.workload.identity/use: "true"
spec:
  serviceAccountName: ${serviceAccountName}
  containers:
    - image: ${acrLoginServer}/azure/azure-workload-identity/msal-go
      imagePullPolicy: Always
      name: oidc
      env:
      - name: KEYVAULT_URL
        value: ${keyVaultUri}
      - name: SECRET_NAME
        value: ${secretName}
      - name: AZURE_CLIENT_ID_GET_SECRET
        value: ${primaryUserAssignedClientId}
      - name: AZURE_CLIENT_ID_SET_SECRET
        value: ${secondaryUserAssignedClientId}
  nodeSelector:
    kubernetes.io/os: linux
EOF

kubectl apply -f workload-identity.yaml

set +x

# Wait for the pod to be running
until [[ $(kubectl get pod quick-start -n ${serviceAccountNamespace} -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') == "True" ]]; do echo "waiting for pod" && sleep 10; done

kubectl logs quick-start -n ${serviceAccountNamespace}