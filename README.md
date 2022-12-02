# Blueprints for Crossplane on Amazon EKS
> **Note**: AWS Blueprints for Crossplane on Amazon Elastic Kubernetes Service is under active development and should be considered a pre-production framework.

Welcome to the AWS Crossplane Blueprints.

## Introduction
[AWS](https://aws.amazon.com/) Crossplane Blueprints is an open source repo to bootstrap Amazon Elastic Kubernetes Service Clusters.
and provision AWS resources with a library of [Crossplane Compositions (XRs)](https://crossplane.io/docs/master/concepts/composition.html) with Composite Resource Definitions (XRDs).

Compositions in this repository enable platform teams to define and offer bespoke AWS infrastructure APIs to the teams of application developers based on
predefined [Composite Resources (XRs)](https://crossplane.io/docs/master/concepts/composition.html), encompassing one or more of AWS [Managed Resources (MRs)](https://crossplane.io/docs/master/concepts/managed-resources.html)

## Features

✅   Bootstrap [Amazon EKS](https://aws.amazon.com/eks/) Cluster and Crossplane with [Terraform](https://www.terraform.io/) \
✅   Bootstrap [Amazon EKS](https://aws.amazon.com/eks/) Cluster and Crossplane with [eksctl](https://eksctl.io/) \
✅   [AWS Provider](https://github.com/crossplane/provider-aws) - Crossplane Compositions for AWS Services \
✅   [AWS IRSA on EKS](https://github.com/crossplane/provider-aws/blob/master/AUTHENTICATION.md#using-iam-roles-for-serviceaccounts) - AWS Provider Config with IRSA enabled  \
✅   Example deployment patterns for [Composite Resources (XRs)](https://crossplane.io/docs/master/concepts/composition.html) for AWS Provider \
✅   Example deployment patterns for [Crossplane Managed Resources (MRs)](https://crossplane.io/docs/master/concepts/managed-resources.html)

## Getting Started

✅   Bootstrap EKS Cluster

This repo provides multiple options to bootstrap Amazon EKS Clusters with Crossplane and AWS Providers.
Checkout the following README for full deployment configuration

- [Bootstrap EKS Cluster with eksctl](bootstrap/eksctl/README.md)
- [Bootstrap EKS Cluster with Terraform](bootstrap/terraform/README.md)

✅   Configure the EKS cluster

Install the Crossplane AWS provider, this provides Custom Resource Definitions (CRDs) that model AWS infrastructure and services (e.g. Amazon Relational Database Service (RDS), EKS clusters, etc.). You will also need to enable IRSA support for your EKS cluster for the
necessary permissions to spin up other AWS services. Refer to the bootstrap README for this configuration.

 - [AWS Provider](https://github.com/crossplane/provider-aws) - Crossplane Managed Resources for AWS Services


✅   Deploy the Examples

With the setup complete, you can then follow instructions on deploying
crossplane compositions or managed resources you want to experiment with. Keep
in mind that the list of compositions and managed resources in this repository
are evolving.

- Deploy the Examples by following [this README](examples/README.md)

✅   Work with nested compositions.

Compositions can be nested to further define and abstract application specific needs.

- Take a quick tour of a [nested composition example](doc/nested-compositions.md)

✅   Work with external secrets.

Crossplane can be configured to publish secrets external to the cluster in which it runs. 

- Try it out with [this guide](doc/vault-integration.md)

✅   Checkout example [Gatekeeper configurations](./examples/gatekeeper/).

## Learn More

- [Amazon EKS](https://aws.amazon.com/eks/)
- [Crossplane](https://crossplane.io/)
- [AWS Provider](https://github.com/crossplane/provider-aws) for Crossplane
  - [API Docs](https://doc.crds.dev/github.com/crossplane/provider-aws) provider-aws

## Debugging
For debugging Compositions, CompositionResourceDefinitions, etc, [please see the debugging guide](doc/debugging.md).

## Maintainers
This repo is maintained by AWS OSS team:

 - [Manabu McCloskey](https://github.com/nabuskey)
 - [Vara Bonthu](https://github.com/vara-bonthu)
 - [Nima Kaviani](https://github.com/nimakaviani)

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the Apache 2.0 License.
