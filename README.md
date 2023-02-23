# Blueprints for Crossplane on Amazon EKS
> **Note**: AWS Blueprints for Crossplane on Amazon Elastic Kubernetes Service is under active development and should be considered a pre-production framework.

Welcome to the AWS Crossplane Blueprints.

## Introduction
[AWS](https://aws.amazon.com/) Crossplane Blueprints is an open source repo to bootstrap Amazon Elastic Kubernetes Service Clusters.
and provision AWS resources with a library of [Crossplane Compositions (XRs)](https://crossplane.io/docs/master/concepts/composition.html) with Composite Resource Definitions (XRDs).

If you are new to Crossplane, it is highly recommended to get yourself familiarized with Crossplane concepts. The [official documentation](https://docs.crossplane.io/master/getting-started/introduction/) and this [blog post](https://blog.upbound.io/crossplane-first-look/) are good starting points. 

Compositions in this repository enable platform teams to define and offer bespoke AWS infrastructure APIs to the teams of application developers based on
predefined [Composite Resources (XRs)](https://crossplane.io/docs/master/concepts/composition.html), encompassing one or more of AWS [Managed Resources (MRs)](https://crossplane.io/docs/master/concepts/managed-resources.html)

## Features

✅   Bootstrap [Amazon EKS](https://aws.amazon.com/eks/) Cluster and Crossplane with [Terraform](https://www.terraform.io/) \
✅   Bootstrap [Amazon EKS](https://aws.amazon.com/eks/) Cluster and Crossplane with [eksctl](https://eksctl.io/) \
✅   [AWS Provider](https://github.com/crossplane/provider-aws) - Crossplane Compositions for AWS Services \
✅   [Upbound AWS Provider](https://github.com/upbound/provider-aws) - Upbound Crossplane Compositions for AWS Services \
✅   [AWS IRSA on EKS](https://github.com/crossplane/provider-aws/blob/master/AUTHENTICATION.md#using-iam-roles-for-serviceaccounts) - AWS Provider Config with IRSA enabled  \
✅ [Patching 101](doc/patching-101.md) - Learn how patches work.
✅   Example deployment patterns for [Composite Resources (XRs)](https://crossplane.io/docs/master/concepts/composition.html) for AWS Provider\
✅   Example deployment patterns for [Crossplane Managed Resources (MRs)](https://crossplane.io/docs/master/concepts/managed-resources.html)

## Getting Started

✅   Bootstrap EKS Cluster

This repo provides multiple options to bootstrap Amazon EKS Clusters with Crossplane and AWS Providers.
Checkout the following README for full deployment configuration

- [Bootstrap EKS Cluster with eksctl](bootstrap/eksctl/README.md)
- [Bootstrap EKS Cluster with Terraform](bootstrap/terraform/README.md)

✅   Configure the EKS cluster

Enable IRSA support for your EKS cluster for the necessary permissions to spin up other AWS services.
Depending on the provider, refer to the bootstrap README for this configuration.

 - [AWS Provider](https://github.com/crossplane/provider-aws) - Crossplane Compositions for AWS Services
 - [Upbound AWS Provider](https://github.com/upbound/provider-aws) - Upbound Crossplane Compositions for AWS Services

✅   Deploy the Examples

With the setup complete, you can then follow instructions on deploying
crossplane compositions or managed resources you want to experiment with. Keep
in mind that the list of compositions and managed resources in this repository
are evolving.

- Deploy the Examples by following [this README](examples/aws-provider/README.md)

✅   Work with nested compositions.

Compositions can be nested to further define and abstract application specific needs.

- Take a quick tour of a [nested composition example](doc/nested-compositions.md)

✅   Work with external secrets.

Crossplane can be configured to publish secrets external to the cluster in which it runs. 

- Try it out with [this guide](doc/vault-integration.md)

✅   Check out the [RDS day 2 operation doc](./doc/rds-day-2.md) 

✅   Checkout example [Gatekeeper configurations](./examples/gatekeeper/).

✅   Upbound AWS provider examples

- Deploy the Examples by following [this README](examples/upbound-aws-provider/README.md)

## Learn More

- [Amazon EKS](https://aws.amazon.com/eks/)
- [Crossplane](https://crossplane.io/)
- [AWS Provider](https://github.com/crossplane/provider-aws) for Crossplane
  - [API Docs](https://doc.crds.dev/github.com/crossplane/provider-aws) provider-aws

## Debugging
For debugging Compositions, CompositionResourceDefinitions, etc, [please see the debugging guide](doc/debugging.md).

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the Apache 2.0 License.
