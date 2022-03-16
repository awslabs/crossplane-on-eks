# AWS Blueprints for Crossplane
> **Note**: AWS Blueprints for Crossplane is under active development and should be considered a pre-production framework.

Welcome to the AWS Crossplane Blueprints.

## Introduction
[AWS](https://aws.amazon.com/) Crossplane Blueprints is an open source repo to bootstrap EKS Clusters
and provision AWS resources with a library of [Crossplane Compositions (XRs)](https://crossplane.io/docs/v1.6/concepts/composition.html) with Composite Resource Definitions (XRDs).

Compositions in this repository enable platform teams to define and offer bespoke AWS infrastructure APIs to the teams of application developers based on
predefined [Composite Resources (XRs)](https://crossplane.io/docs/v1.6/concepts/composition.html), encompassing one or more of AWS [Managed Resources (MRs)](https://crossplane.io/docs/v1.6/concepts/managed-resources.html)

## Features

✅   Bootstrap [Amazon EKS](https://aws.amazon.com/eks/) Cluster and Crossplane with [Terraform](https://www.terraform.io/) \
✅   Bootstrap [Amazon EKS](https://aws.amazon.com/eks/) Cluster and Crossplane with [eksctl](https://eksctl.io/) \
✅   [AWS Provider](https://github.com/crossplane/provider-aws) - Crossplane Compositions for AWS Services \
✅   [Terrajet AWS Provider](https://github.com/crossplane-contrib/provider-jet-aws) - Crossplane Compositions for AWS Services \
✅   [AWS IRSA on EKS](https://github.com/crossplane/provider-aws/blob/master/AUTHENTICATION.md#using-iam-roles-for-serviceaccounts) - AWS Provider Config with IRSA enabled  \
✅   Example deployment patterns for [Composite Resources (XRs)](https://crossplane.io/docs/v1.6/concepts/composition.html) for AWS Provider and Terrajet AWS Provider\
✅   Example deployment patterns for [Crossplane Managed Resources (MRs)](https://crossplane.io/docs/v1.6/concepts/managed-resources.html)

## Getting Started

✅   Bootstrap EKS Cluster

This repo provides multiple options to bootstrap Amazon EKS Clusters with Crossplane and AWS Providers.
Checkout the following README for full deployment configuration

- [Bootstrap EKS Cluster with eksctl](bootstrap/eksctl/README.md)
- [Bootstrap EKS Cluster with Terraform](bootstrap/terraform/README.md)

✅   Configure the EKS cluster

Depending on whether you want to use the jet provider or the default provider
for AWS, you need to install one or both of the crossplane providers on the EKS
cluster. You will also need to enable IRSA support for your EKS cluster for the
necessary permissions to spin up other AWS services. Refer to the bootstrap README for this configuration.

 - [AWS Provider](https://github.com/crossplane/provider-aws) - Crossplane Compositions for AWS Services
 - [Terrajet AWS Provider](https://github.com/crossplane-contrib/provider-jet-aws) - Crossplane Compositions for AWS Services

✅   Deploy the Examples

With the setup complete, you can then follow instructions on deploying
crossplane compositions or managed resources you want to experiment with. Keep
in mind that the list of compositions and managed resources in this repository
are evolving.

- Deploy the Examples by following [this README](examples/README.md)

## Learn More

- [Amazon EKS](https://aws.amazon.com/eks/)
- [Crossplane](https://crossplane.io/)
- [AWS Provider](https://github.com/crossplane/provider-aws) for Crossplane
  - [API Docs](https://doc.crds.dev/github.com/crossplane/provider-aws) provider-aws
- [Terrajet](https://github.com/crossplane/terrajet) [AWS provider](https://github.com/crossplane-contrib/provider-jet-aws) for Crossplane
  - [API Docs](https://doc.crds.dev/github.com/crossplane-contrib/provider-jet-aws) provider-jet-aws

## Debugging
For debugging Compositions, CompositionResourceDefinitions, etc, [please see the debugging guide](doc/debugging.md).

## Maintainers
This repo is maintained by:

 - [Manabu McCloskey](https://github.com/nabuskey)
 - [Vara Bonthu](https://github.com/vara-bonthu)
 - [Nima Kaviani](https://github.com/nimakaviani)
 - [Nuatu Tseggi](https://github.com/Nuatu)

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.
