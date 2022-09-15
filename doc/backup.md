# Backing up Crossplane resources

One of most important part of any application and infrastructure deployment tooling is the ability to backup and restore resources in case of a disaster or a human error.

## Velero

[Velero](https://velero.io/) is an open source tool to safely backup and restore Kubernetes cluster resources. It can be used to backup Crossplane resources as well.

Notes:
- As of Velero version `1.9.1`, you will notice warning messages in Velero cli and server similar to the following:
    ```
    Waited for 1.033772408s due to client-side throttling, not priority and fairness, request: GET:https://api.example.org
    ```
    This is likely due to the go-client library version used by Velero which does not have recent fixes for discovery cache. See [this blog post](https://blog.upbound.io/scaling-kubernetes-to-thousands-of-crds/) for more information around scaling CRDs.

### Setting up Velero
General steps for setting Velero up and restoring resources on Amazon EKS clusters is outlined in [this blog post](https://aws.amazon.com/blogs/containers/backup-and-restore-your-amazon-eks-cluster-resources-using-velero/).

Once Velero is set up, you should be able to backup resources with the following command

```bash
cat <<EOF | kubectl apply -f -
apiVersion: velero.io/v1
kind: Backup
metadata:
  name: test-backup
  namespace: velero
spec:
  includedNamespaces:
  - '*'
EOF
```

Check for status and progress:

```bash
kubectl -n velero describe backup test-backup
```

### Cluster migration
In some cases, you may want to migrate Crossplane resources to another cluster. You may need to use a new version of EKS cluster but want to keep the old version in case of a problem in the new version.

1. Scale down provider pods. This is necessary to ensure provider pods do not conflict with each other and potentially reaching API limits. 
    ```bash
    kubectl get controllerconfig
    # example output
    # NAME                        AGE
    # jet-aws-controller-config   20d
    # provider-aws-config         12d

    cat > patch.yaml <<EOF
    spec:
      replicas: 0
    EOF

    kubectl patch controllerconfig provider-aws-config --patch-file patch.yaml --type merge
    # for the jet provider
    kubectl patch controllerconfig jet-aws-controller-config  --patch-file patch.yaml --type merge
    ```

2. Make a Velero backup (see above)
    ```bash
    cat <<EOF | kubectl apply -f -
    apiVersion: velero.io/v1
    kind: Backup
    metadata:
      name: test-backup
      namespace: velero
    spec:
      includedNamespaces:
      - '*'
    EOF
    ```
3. Restore the newly taken backup into the other cluster
    ```bash
    cat <<EOF | kubectl apply -f -
    apiVersion: velero.io/v1
    kind: Restore
    metadata:
      name: test-restore
      namespace: velero
    spec:
      backupName: test-backup
      includedNamespaces:
      - '*'
    ```
4. Wait for restoration to complete
    ```bash
    kubectl -n velero describe restore test-restore
    ```
5. Scale up provider pods. Reconciliation should continue as usual from now on.
    ```bash
    cat > patch.yaml <<EOF
    spec:
      replicas: 1
    EOF

    kubectl patch controllerconfig provider-aws-config --patch-file patch.yaml --type merge
    # for the jet provider
    kubectl patch controllerconfig jet-aws-controller-config  --patch-file patch.yaml --type merge
    ```
