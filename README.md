# AWS Crossplane Blueprints
Welcome to the AWS Crossplane Blueprints.

## Introduction
[AWS](https://aws.amazon.com/) Crossplane Blueprints is an open source repo to Bootstrap EKS Clusters
and provision AWS resources with a library of Crossplane Compositions(XRD).

[Crossplane](https://crossplane.io/) extends your Kubernetes cluster, providing you with CRDs for managing AWS resources.
Crossplane Composite Resources are opinionated Kubernetes Custom Resources that are composed of Managed Resources.

## Getting Started

✅   Bootstrap EKS Cluster 

This repo provides multiple options to bootstrap Amazon EKS Clusters with Crossplane and AWS Providers.

- [Bootstrap EKS Cluster with eksctl](bootstrap/eksctl/README.md)
- [Bootstrap EKS Cluster with Terraform](bootstrap/terraform/README.md)

✅   Deploy AWS resources with Crossplane
<!--TBD Refer to the S3 example-->


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
This repo is maintained by (A-Z):

 - Manabu McCloskey 
 - Vara Bonthu
 - Nima Kaviani
 - Nuatu Tseggi


## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.
