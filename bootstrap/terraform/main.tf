# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

data "aws_availability_zones" "available" {}

data "aws_eks_cluster" "cluster" {
  name = module.eks_blueprints.eks_cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks_blueprints.eks_cluster_id
}

#---------------------------------------------------------------
# DON'T remove these providers as these are key to deploy EKS Cluster and Kubernetes add-ons
#---------------------------------------------------------------
provider "aws" {
  region = var.region
}

provider "kubernetes" {
  experiments {
    manifest_resource = true
  }
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    token                  = data.aws_eks_cluster_auth.cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  }
}

provider "kubectl" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  apply_retry_count      = 30
}

#---------------------------------------------------------------
# Local variables for your deployment
#---------------------------------------------------------------
locals {
  cluster_version = var.cluster_version
  azs             = data.aws_availability_zones.available.names

  vpc_cidr        = var.vpc_cidr
  vpc_name        = join("-", [var.name, "vpc"])
  cluster_name    = join("-", [var.name, "eks"])
  node_group_name = "mng-ondemand"
}

#---------------------------------------------------------------
# This vpc module creates VPC, 3 Private Subnets, 3 Public Subnets, IGW, Single NAT gateway
# You can comment or remove module if you already have an existing VPC and Subnets. You must add public_subnet_tags, private_subnet_tags to your existing VPC
#---------------------------------------------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "v3.2.0"

  name = local.vpc_name
  cidr = local.vpc_cidr
  azs  = local.azs

  public_subnets  = [for k, v in slice(data.aws_availability_zones.available.names, 0, 2) : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in slice(data.aws_availability_zones.available.names, 0, 2) : cidrsubnet(local.vpc_cidr, 8, k + 10)]

  enable_nat_gateway   = true
  create_igw           = true
  enable_dns_hostnames = true
  single_nat_gateway   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}

#---------------------------------------------------------------
# This module deploys EKS Cluster with one Managed group
#---------------------------------------------------------------
module "eks_blueprints" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints"

  # EKS Cluster VPC and Subnet mandatory config
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  # EKS CONTROL PLANE VARIABLES
  create_eks      = true
  cluster_version = local.cluster_version
  cluster_name    = local.cluster_name

  # EKS MANAGED NODE GROUPS
  managed_node_groups = {
    mg_5 = {
      node_group_name = local.node_group_name
      instance_types  = ["m5.xlarge"]
      min_size        = "1"
      subnet_ids      = module.vpc.private_subnets
      additional_tags = {
        ExtraTag    = "m5-on-demand"
        Name        = "m5-on-demand"
        subnet_type = "private"
      }
    }
  }
}

#---------------------------------------------------------------
# This module deploys Kubernetes add-ons
#---------------------------------------------------------------
module "eks_blueprints_kubernetes_addons" {
  source         = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons"
  eks_cluster_id = module.eks_blueprints.eks_cluster_id

  # Deploy Karpenter Autoscaler
  enable_karpenter = true

  # Deploy Crossplane
  enable_crossplane = true

  crossplane_helm_config = {
    name       = "crossplane"
    chart      = "crossplane"
    repository = "https://charts.crossplane.io/stable/"
    version    = "1.10.1"
    namespace  = "crossplane-system"
    values = [templatefile("${path.module}/values.yaml", {
      operating-system = "linux"
    })]
  }

  # Deploy Crossplane AWS Providers

  # NOTE: Crossplane requires Admin like permissions to create and update resources similar to Terraform deploy role.
  # This example config uses AdministratorAccess for demo purpose only, but you should select a policy with the minimum permissions required to provision your resources

  #
  #---------------------------------------------------------
  # Crossplane AWS Provider deployment
  #   Creates ProviderConfig name as "aws-provider-config"
  #---------------------------------------------------------
  crossplane_aws_provider = {
    enable                   = true
    provider_aws_version     = "v0.33.0"
    additional_irsa_policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  }

  #---------------------------------------------------------
  # Crossplane Terrajet AWS Provider deployment
  #   Creates ProviderConfig name as "jet-aws-provider-config"
  #---------------------------------------------------------
  crossplane_jet_aws_provider = {
    enable                   = true
    provider_aws_version     = "v0.4.2"
    additional_irsa_policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  }

  #---------------------------------------------------------
  # Crossplane Kubernetes Provider deployment
  #   Creates ProviderConfig name as "kubernetes-provider-config"
  #---------------------------------------------------------
  crossplane_kubernetes_provider = {
    enable                      = true
    provider_kubernetes_version = "v0.5.0"
  }

  depends_on = [module.eks_blueprints.managed_node_groups]
}

#---------------------------------------------------------
# Karpenter autoscaler with default provisioner
#---------------------------------------------------------
data "kubectl_path_documents" "karpenter_provisioners" {
  pattern = "${path.module}/karpenter-provisioners/default-provisioner.yaml"
  vars = {
    azs                     = join(",", local.azs)
    iam-instance-profile-id = format("%s-%s", local.cluster_name, local.node_group_name)
    eks-cluster-id          = local.cluster_name
  }
}

resource "kubectl_manifest" "karpenter_provisioner" {
  for_each  = toset(data.kubectl_path_documents.karpenter_provisioners.documents)
  yaml_body = each.value

  depends_on = [module.eks_blueprints_kubernetes_addons]
}
