#!/bin/bash
<< COMMENT

All this has to happen before the demo.
COMMENT 
az group create --name privateCluster --location westus
az extension add --name aks-preview
az feature register --name AllowPrivateEndpoints --namespace Microsoft.ContainerService
az feature register --name AKSPrivateLinkPreview --namespace Microsoft.ContainerService 
az feature register --name AKSAzureStandardLoadBalancer --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.ContainerService 
az aks create -n privateCluster -g privateCluster --load-balancer-sku standard --enable-private-cluster

vnet=$(az network vnet list -g MC_privateCluster_privateCluster_westus -o json)
vnetName=$(echo $vnet | jq -r .[].name)
username=user
password=user@PASS123
subnet=aks-subnet

az vm create --resource-group privateCluster \
--name myVM --location westus \
--image UbuntuLTS \
--vnet-name $vnetName \
--subnet $subnet \
--admin-username $username  --admin-password $password \
--size standard_DS1_v2 
<< COMMENT
create the cluster
create a VM in the same VNET as the cluster 
Create permissions so that the port 22 is exposed to the internet
install the azure cli on the VM
All of this needs to happen on the VM before we can connect to the cluster:

ssh to vm 
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az login
az account set 
sudo az aks install-cli
az aks get-credentials -g privateCluster -n privateCluster

Start by showing the creating process of a private cluster (--enable-private-cluster flag)
Show that this is indeed private by trying to access the cluster through the CLI (should get a 404 error)
Show that we have a VM created that is connected to the vnet of the cluster and has a public IP
Then we ssh into this VM, using the public IP and access the cluster

To reset, just clear both of the terminals used.
To clean up, delete the resource group.
az group delete -g privateCluster
COMMENT
