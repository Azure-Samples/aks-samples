#!/bin/bash

set -e
set -x

prefix="$1"
location="${2-westus2}"
resourceGroupName="$prefix"
deploymentName="$prefix"

CURRENT_DIR="$(realpath $(dirname $0))"

az group create --name $resourceGroupName --location $location

az deployment group create \
  --name $deploymentName \
  --resource-group $resourceGroupName \
  --template-file "${CURRENT_DIR}/main.bicep" \
  --parameters prefix=$prefix
