# Crossplane Blueprint examples

This folder contains example for deploying AWS resources using the following providers

- [AWS Provider](https://github.com/crossplane/provider-aws)
- [Terrajet AWS Provider](https://github.com/crossplane-contrib/provider-jet-aws)

## Usage

The following shows the deployment of VPC using AWS Provider

```shell
cd ~/aws-crossplane-blueprints/examples/aws-provider/managed-resources
kubectl apply -f vpc.yaml

# Verify the resource. When provisioning is complete, you should see READY: True in the output
kubectl get VPC aws-provider-vpc
```
