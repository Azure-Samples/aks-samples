# << COMMENT
# Windows demo setup commands
# COMMENT >>
# Install the aks-preview extension
az extension add --name aks-preview

# Update the extension to make sure you have the latest version installed
az extension update --name aks-preview
az feature register --name WindowsPreview --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.ContainerService
az group create --name windowsDemo --location eastus
PASSWORD_WIN="P@ssw0rd1234"
git clone https://gist.github.com/8d869c43549f2a7a2c0579c565b7d9ef.git
mv 8d869c43549f2a7a2c0579c565b7d9ef windows-demo 
cd window-demo
# ^^^^ OFF SCREEN

# On screen for the video demo
az aks create \
    --resource-group demo \
    --name windowsDemo \
    --node-count 2 \
    --enable-addons monitoring \
    --kubernetes-version 1.14.6 \
    --generate-ssh-keys \
    --windows-admin-password $PASSWORD_WIN \
    --windows-admin-username azureuser \
    --enable-vmss \
    --network-plugin azure

az aks nodepool add \
    --resource-group demo \
    --cluster-name windowsDemo \
    --os-type Windows \
    --name npwin \
    --node-count 2 \
    --kubernetes-version 1.14.6
az aks get-credentials --resource-group demo --name windowsDemo

# Now we're going to go ahead and taint the windows nodes. This will mean that linux workloads that aren't compatibile with running on these nodes will not be
# scheduled on these nodes. On the other hand, pods that have tolerations for the Windows nodes can be schedules on these nodes. This way we make sure that Windows and Linux workloads
# are scheduled with compatible nodes.
kubectl get nodes -l beta.kubernetes.io/os=windows -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | xargs -I XX kubectl taint nodes XX windows=true:NoSchedule

# Give Helm the appropriate permissions to run within the cluster
kubectl apply -f helm-rbac.yaml
helm init --service-account=tiller
helm repo update

# This is where the in-person demo starts
kubectl get nodes
# Show that there are windows and linux nodes running in the same cluster

# Now we're going to go ahead and taint the windows nodes. This will mean that linux workloads that aren't compatibile with running on these nodes will not be
# scheduled on these nodes. On the other hand, pods that have tolerations for the Windows nodes can be schedules on these nodes. This way we make sure that Windows and Linux workloads
# are scheduled with compatible nodes.
kubectl get nodes -l beta.kubernetes.io/os=windows -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | xargs -I XX kubectl taint nodes XX windows=true:NoSchedule

helm install stable/nginx-ingress
# This is a linux workload and we see that it runs on the linux nodes in the cluster
kubectl get pods -o wide
kubectl apply -f iis-svc-ingress.yaml
# We see that the windows workload runs on the windows nodes in the cluster
kubectl get pods -o wide
kubectl get svc # to get exposed IP
# Test in browser
# So here we see that we can use the linux and windows workloads together in the cluster, here using the Linux nginx server to expose the Windows application to the internet, thanks to Windows containers in AKS
