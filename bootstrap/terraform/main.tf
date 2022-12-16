# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks_blueprints.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks_blueprints.eks_cluster_id
}

data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}

locals {
  name   = var.name
  region = var.region

  cluster_version = var.cluster_version
  cluster_name    = local.name

  crossplane_helm_config = {
    #  name       = "crossplane"
    #  chart      = "crossplane"
    #  repository = "https://charts.crossplane.io/stable/"
    version = "1.10.1"
    #  namespace  = "crossplane-system"
    #  values = [templatefile("${path.module}/values.yaml", {
    #    operating-system = "linux"
    #  })]
  }

  # NOTE: Crossplane requires Admin like permissions to create and update resources similar to Terraform deploy role.
  # This example config uses AdministratorAccess for demo purpose only, but you should select a policy with the minimum permissions required to provision your resources
  crossplane_aws_provider = {
    enable                   = true
    provider_aws_version     = "v0.34.0"
    additional_irsa_policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    # name                     = "aws-provider"
    # service_account          = "aws-provider"
    # provider_config          = "default"
    # controller_config        = "aws-controller-config"
  }

  crossplane_kubernetes_provider = {
    enable                      = true
    provider_kubernetes_version = "v0.5.0"
    #  name                        = "kubernetes-provider"
    #  service_account             = "kubernetes-provider"
    #  provider_config             = "default"
    #  controller_config           = "kubernetes-controller-config"
    #  cluster_role                = "cluster-admin"
  }

  vpc_name = local.name
  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 2)

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/awslabs/crossplane-on-eks"
  }
}

#---------------------------------------------------------------
# EKS Blueprints
#---------------------------------------------------------------

module "eks_blueprints" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.18.1"

  # EKS CONTROL PLANE VARIABLES
  cluster_name    = local.cluster_name
  cluster_version = local.cluster_version

  # EKS Cluster VPC and Subnet mandatory config
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  # EKS MANAGED NODE GROUPS
  managed_node_groups = {
    mg = {
      node_group_name = "managed-on-demand"
      instance_types  = ["t3.small"]
      min_size        = 2
      subnet_ids      = module.vpc.private_subnets
    }
  }

  tags = local.tags
}

#---------------------------------------------------------------
# EKS Blueprints Addons
#---------------------------------------------------------------

module "eks_blueprints_kubernetes_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.18.1"

  eks_cluster_id = module.eks_blueprints.eks_cluster_id

  # Deploy Crossplane
  enable_crossplane = true

  crossplane_helm_config = local.crossplane_helm_config

  #---------------------------------------------------------
  # Crossplane AWS Provider deployment
  #   Creates ProviderConfig name as "aws-provider-config"
  #---------------------------------------------------------
  crossplane_aws_provider = local.crossplane_aws_provider

  #---------------------------------------------------------
  # Crossplane Kubernetes Provider deployment
  #   Creates ProviderConfig name as "kubernetes-provider-config"
  #---------------------------------------------------------
  crossplane_kubernetes_provider = local.crossplane_kubernetes_provider

  depends_on = [module.eks_blueprints.managed_node_groups]
}


#---------------------------------------------------------------
# Supporting Resources
#---------------------------------------------------------------

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.vpc_name
  cidr = local.vpc_cidr

  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # Manage so we can name
  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${local.name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${local.name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${local.name}-default" }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}
