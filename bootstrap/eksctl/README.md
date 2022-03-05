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

sed -i '' "s/ACCOUNT_ID/${ACCOUNT_ID}/g" permission-boundary.json

aws iam create-policy \
    --policy-name crossplaneBoundary \
    --policy-document file://permission-boundary.json
```

Create a role for crossplane to use to deploy (admin role with permissions boundary is used here). Note: permissions boundary here is not strict. Purpose of this is to show how it can be used with Crossplane to limit what it can do.

```bash
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

OIDC_PROVIDER=$(aws eks describe-cluster --name crossplane-ssp --query "cluster.identity.oidc.issuer" --output text | sed -e "s/^https:\/\///")

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
          "${OIDC_PROVIDER}:sub": "system:serviceaccount:crossplane-system:provider-aws-*"
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
The need for `provider-aws-*` comes from the fact that crossplane appends random suffix to `provider-aws-` for each releases. See https://github.com/crossplane/provider-aws/blob/master/AUTHENTICATION.md

### IAM roles for service accounts (IRSA)
Annotate the service account to use IRSA.

```
sed -i '' "s/ACCOUNT_ID/${ACCOUNT_ID}/g" crossplane/aws-provider.yaml
```

## Install Crossplane

### Helm

```bash
kubectl create namespace crossplane-system

helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo update

helm install crossplane --namespace crossplane-system --version 1.6.2 crossplane-stable/crossplane
```

```bash
# wait for the provider CRD to be ready.
kubectl wait --for condition=established --timeout=300s crd/providers.pkg.crossplane.io
kubectl apply -f crossplane/aws-provider.yaml

# wait for the AWS provider CRD to be ready.
kubectl wait --for condition=established --timeout=300s crd/providerconfigs.aws.crossplane.io
kubectl apply -f crossplane/aws-provider-config.yaml
```

### Kustomize
Note that Kustomize still relies on Crossplane helm chart because Crossplane doesn't have a published Kustomize base.
