**Virtual Nodes**

**Setup**

To set up the environment for the live demo, run the setup.sh or if you're using the pre-made environment kubectl config use-context virtual-node-autoscale. Then, open up the following tabs:
- Contoso Store (http://store.13.90.60.80.nip.io/)
- Live Metrics Stream for App Insights for Contoso Store
- Grafana Dashboard (localhost:3000)

**Walkthrough**

First, walk through the portal experience of creating a cluster with virtual nodes enabled (Slider on Scaling Tab).


Then, navigate to the application we're running on the cluster (contoso-store). 


Open the Live Metrics Stream tab to demonstrate the current low amount of traffic.


In a split-screen terminal, start the load event (bash ./loadtest.sh)


In another visible terminal, run watch ./kubectl-get-pods.sh

Once you see the Live Metrics start responding to the increase in traffic, navigate to the Grafana dashboard.

Go over the various metrics and explain the graphs (Request per pod, Requests per second. Response time, Number of container instances)


**Reset**

 The loadtest only runs for about 5 minutes, so no reset needed here, beyond clearing the terminals you're using.
No clean up!