curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az login
az account set 
sudo az aks install-cli
az aks get-credentials -g privateCluster -n privateCluster