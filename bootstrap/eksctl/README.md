# EKS Cluster bootstrap with eksctl for Crossplane

# Installation
## Required tools
- helm
- kubect
- AWS CLI
- kustomize


## Create EKS Cluster

```bash
# if you would like to use fargate
eksctl create cluster -f eksctl-fargate.yaml

# if you do not want fargate
eksctl create cluster -f eksctl.yaml
```

## IAM Setup
Create permission boundary:
```bash
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

sed -i.bak "s/ACCOUNT_ID/${ACCOUNT_ID}/g" permission-boundary.json

aws iam create-policy \
    --policy-name crossplaneBoundary \
    --policy-document file://permission-boundary.json
```

Create a role for crossplane to use to deploy (admin role with permissions boundary is used here). Note: permissions boundary here is not strict. Purpose of this is to show how it can be used with Crossplane to limit what it can do.

```bash
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

OIDC_PROVIDER=$(aws eks describe-cluster --name crossplane-blueprints --query "cluster.identity.oidc.issuer" --output text | sed -e "s/^https:\/\///")

PERMISSION_BOUNDARY_ARN="arn:aws:iam::${ACCOUNT_ID}:policy/crossplaneBoundary"

read -r -d '' TRUST_RELATIONSHIP <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${ACCOUNT_ID}:oidc-provider/${OIDC_PROVIDER}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringLike": {
          "${OIDC_PROVIDER}:sub": "system:serviceaccount:crossplane-system:provider-*"
        }
      }
    }
  ]
}
EOF
echo "${TRUST_RELATIONSHIP}" > trust.json

aws iam create-role --role-name crossplane-provider-aws --assume-role-policy-document file://trust.json --description "IAM role for provider-aws" --permissions-boundary ${PERMISSION_BOUNDARY_ARN}

aws iam attach-role-policy --role-name crossplane-provider-aws --policy-arn=arn:aws:iam::aws:policy/AdministratorAccess

```
The need for `provider-*` comes from the fact that crossplane appends random suffix to `provider-aws-` for each releases. See https://github.com/crossplane/provider-aws/blob/master/AUTHENTICATION.md

If you would like to tighten this further, you can modify the trust relationship with the exact service account name after the service account is created. For example:
```bash
kubectl get sa -n crossplane-system

NAME                               SECRETS   AGE
provider-aws-f78664a342f1          1         52m
```
Update the trust relationship as follows:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${ACCOUNT_ID}:oidc-provider/${OIDC_PROVIDER}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${OIDC_PROVIDER}:aud": "sts.amazonaws.com",
          "${OIDC_PROVIDER}:sub": "system:serviceaccount:crossplane-system:provider-aws-f78664a342f1"
        }
      }
    }
  ]
}
```
See the [IRSA documentation](https://docs.aws.amazon.com/eks/latest/userguide/create-service-account-iam-policy-and-role.html) and the [IRSA troubleshooting guide](https://aws.amazon.com/premiumsupport/knowledge-center/eks-troubleshoot-IRSA-errors/) for more information.
### IAM roles for service accounts (IRSA)
Annotate the service account to use IRSA.

```bash
sed -i.bak "s/ACCOUNT_ID/${ACCOUNT_ID}/g" crossplane/aws-provider.yaml
sed -i.bak "s/ACCOUNT_ID/${ACCOUNT_ID}/g" crossplane/upbound-aws-provider.yaml
```

## Install Crossplane

### Helm


#### (Option 1) Install [Crossplane community helm chart](https://github.com/crossplane/crossplane/tree/master/cluster/charts/crossplane)
```bash
helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo update

helm install crossplane crossplane-stable/crossplane \
--namespace crossplane-system \
--create-namespace \
--set args='{"--enable-environment-configs"}' \
--version 1.15.0 # Get the latest version from https://github.com/crossplane/crossplane/releases

```

#### (Option 2) Install Crossplane using [Upbound Universal Crossplane (UXP) helm chart](https://github.com/upbound/universal-crossplane/tree/main/cluster/charts/universal-crossplane)

```bash
helm repo add upbound-stable https://charts.upbound.io/stable
helm repo update

helm install crossplane upbound-stable/universal-crossplane \
--namespace crossplane-system \
--create-namespace \
--version 1.10.2-up.1 # Get the latest version from https://github.com/upbound/universal-crossplane/releases

```
> Note: Upbound install documentation use namespace `upbound-system`, we use `crossplane-system` to be compatible with the examples in this repository and easier to switch from crossplane upstream to upbound downstream.


### Install Crossplane Providers

```bash
# wait for the Crossplane provider CRD to be ready.
kubectl wait --for condition=established --timeout=300s crd/providers.pkg.crossplane.io
kubectl apply -f crossplane/aws-provider.yaml
kubectl apply -f crossplane/upbound-aws-provider.yaml
kubectl apply -f crossplane/kubernetes-provider.yaml
kubectl create serviceaccount helm-provider -n crossplane-system
kubectl apply -f crossplane/helm/clusterrolebinding.yaml
kubectl apply -f crossplane/helm/controller-config.yaml
kubectl apply -f crossplane/helm/provider.yaml
```

```bash
# wait for the AWS OSS provider CRD to be ready.
kubectl wait --for condition=established --timeout=300s crd/providerconfigs.aws.crossplane.io
kubectl apply -f crossplane/aws-provider-config.yaml
```

```bash
# wait for the AWS Upbound provider CRD to be ready.
kubectl wait --for condition=established --timeout=300s crd/providerconfigs.aws.upbound.io
kubectl apply -f crossplane/upbound-aws-provider-config.yaml
```

```bash
# wait for the Kubernetes provider CRD to be ready
kubectl wait --for condition=established --timeout=300s crd/providerconfigs.kubernetes.crossplane.io
kubectl apply -f crossplane/kubernetes-provider-config.yaml
```

```bash
# wait for the Helm provider CRD to be ready
kubectl wait --for condition=established --timeout=300s crd/providerconfigs.helm.crossplane.io
kubectl apply -f crossplane/helm/provider-config.yaml
```
### Deploy ArgoCD in cluster (required for examples that use ArgoCD)
> Note: The default ArgoCD configuration needs 3 nodes in separate AZs to deploy correctly. By default, eksctl deploys with 2 nodes and no autoscalers.

```bash
helm repo add argo-helm https://argoproj.github.io/argo-helm
helm repo update

helm install -f crossplane/argocd/argocd-values.yaml argo-cd argo-helm/argo-cd \
--namespace argocd \
--create-namespace \
--version 5.46.1 # ArgoCD v2.8.3
```
### Apply `EnvironmentConfig`
Insert required values in manifest
```bash
VPC_ID=$(aws eks describe-cluster --name crossplane-blueprints --query "cluster.resourcesVpcConfig.vpcId" --output text)

sed -i.bak "s/ACCOUNT_ID/${ACCOUNT_ID}/g" crossplane/environmentconfig.yaml
sed -i "s/OIDC_PROVIDER/$(echo $OIDC_PROVIDER |sed -r 's/([\$\.\*\/\[\\^])/\\\1/g'|sed 's/[]]/\[]]/g')/g" crossplane/environmentconfig.yaml
sed -i "s/VPC_ID/${VPC_ID}/g" crossplane/environmentconfig.yaml
```
Apply manifest
```bash
kubectl apply -f crossplane/environmentconfig.yaml 
```
### Kustomize
Note that Kustomize still relies on Crossplane helm chart because Crossplane doesn't have a published Kustomize base.


## Uninstall

### Uninstall Crossplane Providers


```bash
# Delete the providerconfig
kubectl delete -f crossplane/aws-provider-config.yaml
kubectl delete -f crossplane/upbound-aws-provider-config.yaml
kubectl delete -f crossplane/kubernetes-provider-config.yaml

# Delete the provider and provider controller config
kubectl delete -f crossplane/aws-provider.yaml
kubectl delete -f crossplane/upbound-aws-provider.yaml
kubectl delete -f crossplane/kubernetes-provider.yaml
```

### Uninstall Crossplane

```bash
helm uninstall crossplane -n crossplane-system
```
