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

## Deploy the examples

[sqs-lambda-s3](composite-resources/serverless-examples/sqs-lambda-s3/README.md)<br>
[sns-sqs-lambda-s3](composite-resources/serverless-examples/sns-sqs-lambda-s3/README.md)
