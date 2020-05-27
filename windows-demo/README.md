
To setup the demo, run the setup.sh in this folder to create your own environment.

Once you have that, let's start the demo!

Now we're going to go ahead and taint the windows nodes. This will mean that Linux workloads that aren't compatible with running on these nodes will not be scheduled on these nodes. On the other hand, pods that have tolerations for the Windows nodes can be schedules on these nodes. This way we make sure that Windows and Linux workloads
are scheduled with compatible nodes.
```
kubectl get nodes -l beta.kubernetes.io/os=windows -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | xargs -I XX kubectl taint nodes XX windows=true:NoSchedule
```
Give Helm the appropriate permissions to run within the cluster. (We have to do this step after the node taint, so that the tiller pod doesn't land on an incompatible node.)

```
kubectl apply -f helm-rbac.yaml
helm init --service-account=tiller
helm repo update
```

Now we can see that there are windows and linux nodes running in the same cluster.
```
kubectl get nodes


```

Now, we're going to go ahead and taint the windows nodes. This will mean that linux workloads that aren't compatibile with running on these nodes will not be scheduled on these nodes. On the other hand, pods that have tolerations for the Windows nodes can be schedules on these nodes. This way we make sure that Windows and Linux workloads are scheduled with compatible nodes.

```
kubectl get nodes -l beta.kubernetes.io/os=windows -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | xargs -I XX kubectl taint nodes XX windows=true:NoSchedule
```

We're going to demonstrate that we can run a linux workload on this cluster.
```
helm install stable/nginx-ingress
kubectl get pods -o wide
```
You'll see that it was placed on the linux nodes.

```
kubectl apply -f iis-svc-ingress.yaml
```
And we see that the windows workload runs on the windows nodes in the cluster.

```
kubectl get pods -o wide
kubectl get svc # to get exposed IP
```

Test in browser to show that the windows server is indeed up and running.

So, here we see that we can use the Linux and Windows workloads together in the cluster, here using the Linux nginx server to expose the Windows application to the internet, thanks to Windows containers in AKS.
