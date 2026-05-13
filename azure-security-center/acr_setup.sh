#!/bin/bash

read -p "Enter a unique name for your Azure Container Registry: " acr_name
az group create --name ASC-demo --location eastus
az acr create -n $acr_name -g ASC-demo --sku Basic
az acr login --name $acr_name