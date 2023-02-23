# Crossplane Blueprint examples
This folder contains examples for deploying AWS resources using the following providers

- [AWS Provider](https://github.com/crossplane/provider-aws)

## Pre-requisites:
 - EKS Cluster bootstrap deployment
 - Crossplane deployment in bootstrap cluster
 - ProviderConfig deployment with injected identity

Follow these links to bootstrap the cluster
- Bootstrap the cluster with [Terraform](../../bootstrap/terraform/README.md)
- Bootstrap the cluster with [eksctl](../../bootstrap/eksctl/README.md)


## AWS Provider
The following steps demonstrates VPC example composition deployment with **AWS Provider**

### Deploy Composition and XRD
Deploys VPC Composition file and XRD definition file

```shell
kubectl apply -f ../../compositions/aws-provider/vpc
```

### Deploy Application example
Deploys VPC claim resource which uses the above composition.

```shell
kubectl apply -f composite-resources/vpc/vpc.yaml
```

## Deploy Managed resource for AWS Provider

The following shows the deployment of VPC using AWS Provider

```shell
kubectl apply -f managed-resources/vpc.yaml

# Verify the resource. When provisioning is complete, you should see READY: True in the output
kubectl get VPC aws-provider-vpc
```

## Crossplane Kubernetes Provider

The following example shows the creation of Namespace with Crossplane Kuberentes provider

Note: [Kubernetes Provider](https://github.com/crossplane-contrib/provider-kubernetes) should be deployed as a pre-requisite for this example.
Terraform and eksctl bootstrap scripts deploys kubernetes provider in EKS Cluster.

```shell
kubectl apply -f ../kubernetes-provider/test-namespace.yaml

# Verify the resource
kubectl get namespaces  

NAME                        STATUS   AGE
crossplane-test-namespace   Active   81s

```
