# Crossplane Blueprint examples

This folder contains example for deploying AWS resources using the following providers

- [AWS Provider](https://github.com/crossplane/provider-aws)
- [Terrajet AWS Provider](https://github.com/crossplane-contrib/provider-jet-aws)

## Option1: Deployment Steps for AWS Provider

### Deploy Composition and XRD

```shell
kubectl apply -f compositions/aws-provider/vpc
```

### Deploy Application example

```shell
kubectl apply -f examples/aws-provider/composite-resources/vpc/vpc.yaml
```

## Option2: Deployment Steps for Jet AWS Provider

The following steps demonstrate the example to deploy the VPC with Jet AWS Provider

### Deploy Composition and XRD

```shell
kubectl apply -f compositions/terrajet-aws-provider/vpc
```

### Deploy Application example

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
