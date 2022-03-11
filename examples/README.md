# Crossplane Blueprint examples
This folder contains examples for deploying AWS resources using the following providers

- [AWS Provider](https://github.com/crossplane/provider-aws)
- [Terrajet AWS Provider](https://github.com/crossplane-contrib/provider-jet-aws)

## Pre-requisites:
 - EKS Cluster bootstrap deployment
 - Crossplane deployment in bootstrap cluster
 - AWS Provider and Terrajet AWS Provider deployment
 - ProviderConfig deployment with injected identity

Follow these links to bootstrap the cluster
- Bootstrap the cluster with [Terraform](../bootstrap/terraform/README.md)
- Bootstrap the cluster with [eksctl](../bootstrap/eksctl/README.md)


## Option1 - AWS Provider
The following steps demonstrates VPC example composition deployment with **AWS Provider**

### Deploy Composition and XRD
Deploys VPC Composition file and XRD definition file

```shell
kubectl apply -f compositions/aws-provider/vpc
```

### Deploy Application example
Deploys VPC claim resource which uses the above composition.

```shell
kubectl apply -f examples/aws-provider/composite-resources/vpc/vpc.yaml
```

## Option2: Jet AWS Provider
The following steps demonstrates VPC example composition deployment with **Jet AWS Provider**

### Deploy Composition and XRD
Deploys VPC Composition file and XRD definition file
```shell
kubectl apply -f compositions/terrajet-aws-provider/vpc
```

### Deploy Application example
Deploys VPC claim resource which uses the above composition.
```shell
kubectl apply -f examples/terrajet-aws-provider/composition-resources/vpc.yaml
```

## Option3: Deploy Managed resource for AWS Provider

The following shows the deployment of VPC using AWS Provider

```shell
kubectl apply -f examples/aws-provider/managed-resources/vpc.yaml

# Verify the resource. When provisioning is complete, you should see READY: True in the output
kubectl get VPC aws-provider-vpc
```
