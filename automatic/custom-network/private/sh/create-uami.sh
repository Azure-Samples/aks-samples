az identity create \
--resource-group ${RG_NAME} \
 --name ${IDENTITY_NAME} \
 --location ${LOCATION}

IDENTITY_PRINCIPAL_ID=$(az identity show --resource-group ${RG_NAME} --name ${IDENTITY_NAME} --query principalId -o tsv)

az role assignment create \
--scope "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RG_NAME}/providers/Microsoft.Network/virtualNetworks/${VNET_NAME}" \
--role "Network Contributor" \
--assignee ${IDENTITY_PRINCIPAL_ID}
