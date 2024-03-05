# Upbound AWS Provider Crossplane Blueprint Examples
This folder contains examples for deploying AWS resources using the following provider and related specs

- [Upbound AWS Provider](https://github.com/upbound/provider-aws)
- [CRDs specs](https://marketplace.upbound.io/providers/upbound/provider-aws/)

## Pre-requisites:
 - EKS Cluster bootstrap deployment
 - Crossplane deployment in bootstrap cluster
 - ProviderConfig deployment with injected identity

Follow these links to bootstrap the cluster
- Bootstrap the cluster with [Terraform](../../bootstrap/terraform/README.md)
- Bootstrap the cluster with [eksctl](../../bootstrap/eksctl/README.md)


## Create managed resources to validate Upbound AWS Provider configuration
The following steps demonstrates VPC end S3 managed resources examples with **Upbound AWS Provider**


### Deploy VPC Managed Resource for Upbound AWS Provider

```shell
kubectl apply -f managed-resources/ec2/vpc.yaml

# Verify the resource. When provisioning is complete, you should see READY: True in the output
kubectl get vpcs
```

### Deploy S3 Managed Resource for Upbound AWS Provider
```shell
kubectl create -f managed-resources/s3/bucket.yaml

# Verify the resource. When provisioning is complete, you should see READY: True in the output
kubectl get buckets
```

## Authenticate with an existing EKS Cluster using upbound AWS Provider

The following shows an example of how to authenticate and retrieve `kubeconfig` from an existing remote EKS Cluster using AWS Provider

```shell
# Please make sure to replace `<your-cluster-name>` with your EKS cluster name in the below file before applying.
kubectl apply -f managed-resources/eks/eks-clusterauth.yaml

# Verify the resource. When authentication is complete, you should see READY: True in the output.
kubectl get clusterauths.eks.aws.upbound.io

NAME                               READY   SYNCED   EXTERNAL-NAME                      AGE
eks-x86-us-east-2-1-28-blueprint   True    True     eks-x86-us-east-2-1-28-blueprint   11d

# Verify if the secret has pulled the `kubeconfig` of a remote cluster to management cluster.
kubectl describe secret eks-x86-us-east-2-1-28-eks-connection -n upbound-system

Name:         eks-x86-us-east-2-1-28-eks-connection
Namespace:    upbound-system
Labels:       <none>
Annotations:  <none>

Type:  connection.crossplane.io/v1alpha1

Data
====
clusterCA:   1107 bytes
endpoint:    72 bytes
kubeconfig:  4314 bytes
```

### Deploys an EKS Addon for Upbound AWS Provider

The following shows an example of how to deploy an EKS Addon on an EKS Cluster from a management EKS Cluster using Upbound AWS Provider

```shell
# Please make sure to replace `<your-cluster-name>` with your EKS cluster name in the below file before applying.
kubectl create -f managed-resources/eks/eks-addon.yaml

# Verify the resource. When provisioning is complete, you should see READY: True in the output
kubectl get addon.eks.aws.upbound.io -A

NAME             READY   SYNCED   EXTERNAL-NAME                              AGE
vpc-cni          True    True     eks-x86-us-east-2-1-28-blueprint:vpc-cni   12d
```

## Deploy the examples

- [sqs-lambda-s3](composite-resources/serverless-examples/sqs-lambda-s3/README.md)
- [sns-sqs-lambda-s3](composite-resources/serverless-examples/sns-sqs-lambda-s3/README.md)
- [kinesis-lambda-s3-logs](composite-resources/serverless-examples/kinesis-lambda-s3-logs/README.md)
