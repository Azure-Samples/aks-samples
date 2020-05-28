# Reset
# Now to reset the in-person demo, run the following commands:
kubectl delete -f iis-svc-ingress.yaml
helm delete $(helm ls --short)
kubectl taint nodes --all windows:NoSchedule-