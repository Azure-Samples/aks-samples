**Azure Policy for Azure Kubernetes Service**

:::image type="content" source="../../aks-demos/azure-policy/Azure Policy for AKS.jpg" alt-text="Azure Policy for AKS Diagram":::

**Setup**

To setup the demo, you can run the setup.sh script in this folder (remember that the CLI commands for Azure Policy are in preview and aren't yet reliable), or you can use the azure-policy context in the provided KUBECONFIG.

If you want to setup your own environment:
- Join the private preview
- Create an AKS cluster
- Create a policy assignment for "Do not allow privileged container in AKS"
- Enable policy add-on for your cluster
- Profit

**Walkthrough**

In this demo, we'll be going over enabling policy for an existing AKS cluster, and then trying to deploy a container that disobeys that policy. 
Moving forward, this demo assumes you have an existing cluster and that you've been whitelisted for private preview.

First, enable the azure-policy add-on for your cluster. You can do this through portal. Navigate to your AKS cluster, and select Policy from the right-hand toolbar. Now, hit 'Enable add-on'. (Note: you need to be anable for the private preview for Azure Policy for AKS and have your subscription whitelisted.)

Now, navigate to Policy in Azure Portal. If you haven't joined preview, you can do so on this page. Click on definitions. Notice that here you can see all of the policy definitions so far in use in your subscription. Here you can see that I just have the basic assignments from my security center subscription. 

Now, we're going to go ahead and create a new policy assignment. We're going to filter by Kubernetes Service and take a look at all of the different built-definitions that we can apply.

Let's go with 'Do not allow privileged containers in AKS. We're going to set the scope to be the resource group our AKS cluster resides in. Make sure that Azure Policy is going to enforce this policy in our cluster. And create! ***If you're running the live demo, just walk through the process. You've already creating the policy assignment through the demo setup***

Now, let's see what's going on in our cluster. 

```
kubectl get pods -o wide --all-namespaces
```

You'll notice that we now have a Azure Policy pod running the cluster. This is what's going to enforce our policy definition in our cluster. To demonstrate this, I'm going to try to deploy a privileged container in the cluster. 

First, let's take a look at what's in here.

```
cat privileged-container.yaml
# or if you're using cmd
type privileged-container.yaml
```

Now, let's try to deploy it.
```
kubectl create -f privileged-container.yaml
```

And you'll see that Azure Policy stops the operation from being carried through. 


