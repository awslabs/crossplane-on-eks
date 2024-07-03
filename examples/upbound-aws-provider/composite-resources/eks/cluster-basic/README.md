# Example to deploy a basic EKS cluster with one nodegroup
This example provides a Claim that deploys an EKS Cluster with no Addons and a single Nodegroup. First, it applies the Crossplane XRDs and Composition. Then it applies an ArgoCD app that contains the Crossplane Claim. The Crossplane creates the EKS Cluster and Nodegroup resources.
As the Claim requires some input parameters from the target environment, to use it it's first required to fork the repository to your own account or copy it to a private repository.
Then edit the eks-cluster-basic.yaml file, providing the following informations:
 - The Subnet IDs to provision the EKS Cluster control-plane private endpoints and the Nodegroup hosts.
 - The ProviderConfig name that should be used to create the EKS Cluster.
In addition to that, it's also required to edit the 'argocd-eks-app.yaml' file, editing the following information:
 - 'spec.source.repoURL' to point to your fork or private copy of the repository.

## Pre-requisites
 - [Upbound AWS Provider Crossplane Blueprint Examples](../../README.md)


### Deploy XRDs and Compositions
```shell
kubectl apply -k .
```

Verify the XRDs
```shell
kubectl get xrds
```

Expected output
```
NAME                                               ESTABLISHED   OFFERED   AGE
xekss.awsblueprints.io                             True          True      5m4s
```

Verify the Compositions
```shell
kubectl get compositions
```

Expected output. Note: the output might contain more compositions but these are the ones uses by the claim in the next step
```
NAME                                              XR-KIND           XR-APIVERSION                              AGE
xeks.awsblueprints.io                             XEks              awsblueprints.io/v1alpha1                  5m12s
```

### Validate `EnvironmentConfig`

Crossplane `environmentconfig` named `cluster` is created by the bootstrap terraform code. Validate it exists and contains proper values
```
kubectl get environmentconfig cluster -o yaml
```
Expected output
```
apiVersion: apiextensions.crossplane.io/v1alpha1
kind: EnvironmentConfig
metadata:
  name: cluster
data:
  awsAccountID: <account_id>
  eksOIDC: <oidc>
```

### Apply ArgoCD application
The applications contains the claim and the deployment.
```
kubectl apply -f argocd-eks-app.yaml
```

### Navigate to the ArgoCD UI
Find the ArgoCD URL:
```
kubectl -n argocd get svc argo-cd-argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```
The username is `admin` and the password can be obtained by executing:
```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### Sync the ArgoCD app and watch the eks-app come up.
![EKS App ArgoCD](../../diagrams/argocd-eks-app-sync.png)
