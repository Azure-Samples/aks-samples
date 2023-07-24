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

keyId=$(az deployment group show \
  -g $resourceGroupName  \
  -n $deploymentName \
  --query properties.outputs.keyId.value \
  -o tsv)