# AWS Blueprints for Crossplane
> **Note**: AWS Blueprints for Crossplane is an active development and should be considered a pre-production framework. 

Welcome to the AWS Crossplane Blueprints.

## Introduction
[AWS](https://aws.amazon.com/) Crossplane Blueprints is an open source repo to Bootstrap EKS Clusters
and provision AWS resources with a library of [Crossplane Compositions(XRs)](https://crossplane.io/docs/v1.6/concepts/composition.html) with Composite Resource Definitions(XRDs).

Compositions allow platform teams to define and offer bespoke infrastructure APIs to the teams of application developers.
Resources within these APIs are [Composite Resource(XRs)](https://crossplane.io/docs/v1.6/concepts/composition.html) and it is composed of one or more [Managed Resources(MRs)](https://crossplane.io/docs/v1.6/concepts/managed-resources.html)

[Crossplane](https://crossplane.io/) extends your Kubernetes cluster, providing you with CRDs for managing AWS resources.
Crossplane Composite Resources are opinionated Kubernetes Custom Resources that are composed of Managed Resources. 

## Features

✅   Bootstrap [Amazon EKS](https://aws.amazon.com/eks/) Cluster and Crossplane with [Terraform](https://www.terraform.io/) \
✅   Bootstrap [Amazon EKS](https://aws.amazon.com/eks/) Cluster and Crossplane with [eksctl](https://eksctl.io/) \
✅   [AWS Provider](https://github.com/crossplane/provider-aws) - Crossplane Compositions for AWS Services \
✅   [Terrajet AWS Provider](https://github.com/crossplane-contrib/provider-jet-aws) - Crossplane Compositions for AWS Services \
✅   [AWS IRSA on EKS](https://github.com/crossplane/provider-aws) - AWS Provider Config with IRSA enabled  \
✅   Example deployment patterns for [Composite Resources(XRs)](https://crossplane.io/docs/v1.6/concepts/composition.html) for AWS Provider and Terrajet AWS Provider\
✅   Example deployment patterns for [Crossplane Managed Resources(MRs)](https://crossplane.io/docs/v1.6/concepts/managed-resources.html)

## Getting Started

✅   Bootstrap EKS Cluster

This repo provides multiple options to bootstrap Amazon EKS Clusters with Crossplane and AWS Providers. 
Checkout the following README for full deployment configuration 

- [Bootstrap EKS Cluster with eksctl](bootstrap/eksctl/README.md)
- [Bootstrap EKS Cluster with Terraform](bootstrap/terraform/README.md)

## Learn More

- [Amazon EKS](https://aws.amazon.com/eks/)
- [Crossplane](https://crossplane.io/)
- [AWS Provider](https://github.com/crossplane/provider-aws) for Crossplane
  - [API Docs](https://doc.crds.dev/github.com/crossplane/provider-aws) provider-aws
- [Terrajet](https://github.com/crossplane-contrib/provider-jet-aws/releases) AWS provider for Crossplane
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
