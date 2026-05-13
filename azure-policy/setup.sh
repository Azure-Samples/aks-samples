# To set-up this demo, do the following:

# Join preview for Azure Policy with AKS
# Create an AKS cluster
# Add a 'Do not allow privileged containers' policy on the cluster
# Wait for the policy to create (15 minutes)
# Enable Policy Add-on for the cluster

# Creating resource group
az group create -g azure-policy-rg -l westus

# Creating cluster
az aks create -n azure-policy -g azure-policy-rg --node-count 1 

# Enable Azure Policy on this cluster
az aks enable-addons --addons azure-policy --name azure-policy --resource-group azure-policy-rg

# Creating policy
subscription_id=$(az account show -o json --query id)
scope=/subscriptions/$subscription_id/resourceGroups/azure-policy-rg
az policy assignment create --name 'no-privileged-containers' --display-name '[Limited Preview]: Do not allow privileged containers in AKS' --scope scope --policy '/providers/Microsoft.Authorization/policyDefinitions/7ce7ac02-a5c6-45d6-8d1b-844feb1c1531"'
az aks enable-addons --addons azure-policy --name azure-policy --resource-group azure-policy-rg