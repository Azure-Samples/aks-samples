# Secrets

* [ ] ConfigMaps are not used to hold confidential data.
* [x] Encryption at rest is configured for the Secret API.
* [ ] If appropriate, a mechanism to inject secrets stored in third-party storage is deployed and available.
* [ ] Service account tokens are not mounted in pods that don't require them.
* [ ] Bound service account token volume is in-use instead of non-expiring tokens.
Secrets required for pods should be stored within Kubernetes Secrets as opposed to alternatives such as ConfigMap. Secret resources stored within etcd should be encrypted at rest.

Pods needing secrets should have these automatically mounted through volumes, preferably stored in memory like with the emptyDir.medium option. Mechanism can be used to also inject secrets from third-party storages as volume, like the Secrets Store CSI Driver. This should be done preferentially as compared to providing the pods service account RBAC access to secrets. This would allow adding secrets into the pod as environment variables or files. Please note that the environment variable method might be more prone to leakage due to crash dumps in logs and the non-confidential nature of environment variable in Linux, as opposed to the permission mechanism on files.

Service account tokens should not be mounted into pods that do not require them. This can be configured by setting automountServiceAccountToken to false either within the service account to apply throughout the namespace or specifically for a pod. For Kubernetes v1.22 and above, use Bound Service Accounts for time-bound service account credentials.

https://kubernetes.io/docs/concepts/security/security-checklist/#secrets
