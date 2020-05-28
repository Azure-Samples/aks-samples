**Setup**

To begin this demo, you'll need a subscription that had been whitelisted by the Azure Security Center team, an AKS cluster in that subscription, and a standard Security Center subscription.

For the container registry scanning, you'll need a container registry, which will be created for you in acr_setup.sh

From the security recommendations and alerts, you'll need to create a cluster you can access in the portal. You can do that by running alerts_setup.sh

**Azure Container Registry Scanning**

First, we're going to demo Azure Container's Registry new container scanning. The registry scans images as they are pushed to check for vulnerability. 

We're going to login in to our container registry using

```
az acr login -n <ACR_NAME>
````

Now, we're going to pull a vulnerable image and push it to our registry.

```
docker pull docker.io/vulnerables/web-dvw
docker tag <image> <registry name>.azurecr.io /<RepositoryName>:<tag
docker push <registry name>.azurecr.io/<RepositoryName>:<tag
```

After a few minutes, Azure Security Center should have scanned our image. So, let's open up Azure Security Center > Compute & Apps > Containers
Our registry should be listed here. Go ahead and click on the registry to view details. You should see a recommendation called "Vulnerabilities in Azure Container Registry images should be remediated (Preview)" 
Click on the recommendation to review the ‘Description’, ‘General Information’, ‘Threats’ and ‘Remediation Steps’ 


**Azure Security Center Integration with AKS**

Now we're going to look at how Azure Security Center (ASC) is integrated with Azure Kubernetes Service (AKS).

First, we need ASC to discover our new cluster (this can take a few hours). 

Once that's done, navigate to Azure Security Center > Compute & Apps > Containers, where we'll see our cluster listed.

Click on the cluster, and let's review the security recommendations.

Reccommendations are listed in both the 'Reccommendations' and 'Passed Assessments' tabs at the bottom of the window.

Click on a Recommendation, and review the ‘Description’, ‘General Info’, ‘Threats’ and ‘Remediation Steps’.
Click on ‘Take Action’, and you will be directed to the AKS resource page to complete remediation.

We can also see these recommendations in a different view. Click on the 'Recommendations' tab on the right-hand side of Azure Security Center. Filter the recommendations by typing in 'Kubernetes' into the search bar. Now you can view recommendations across all of the clusters in your subscription.

**Security Alerts with AKS**

 To demonstrate security alerts with AKS, we're going to deploy some containers that will simulate malicious activity. Make sure your context to set to the right cluster. We don't want to expose any other clusters to these security risks.

 ```
 az aks get-credentials -n <CLUSTER_NAME> -g <CLUSTER_RG>
 kubectl config current-context
 ```

Now, let's deploy the containers.
```
kubectl create -f ASC-Trigger-AKS-Alerts.yaml
```

After waiting about an hour, security alerts should start to pop up in ASC. Head to Azure Security Center > Security Alerts. Here, you can filter by alerts in the last 24 hours, to see the alerts from the containers we deployed.


Thanks to Maya Herskovic and the ASC Team for providing some of the documentation for this demo. 