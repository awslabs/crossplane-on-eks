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
  name            = var.name
  region          = var.region
  
  cluster_version = var.cluster_version
  cluster_name    = local.name
  
  crossplane_aws_provider = var.crossplane_aws_provider
  crossplane_kubernetes_provider = var.crossplane_kubernetes_provider
  
  vpc_name        = local.name
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
  source = "github.com/aws-ia/terraform-aws-eks-blueprints"

  # EKS CONTROL PLANE VARIABLES
  cluster_name    = local.cluster_name
  cluster_version = local.cluster_version

  # EKS Cluster VPC and Subnet mandatory config
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  # EKS MANAGED NODE GROUPS
  managed_node_groups = {
    mg = {
      node_group_name = "managed-spot"
      capacity_type   = "SPOT"
      instance_types  = ["t3.small", "t3a.small", "t3.medium"]
      min_size        = 1
      max_size        = 3
      desired_size    = 3
      subnet_ids      = module.vpc.private_subnets
    }
  }

  tags = local.tags
}

#---------------------------------------------------------------
# EKS Blueprints Addons
#---------------------------------------------------------------

 module "eks_blueprints_kubernetes_addons" {
  # TODO flip this before merging PR
  #source         = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons"
  source = "github.com/csantanapr/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=crossplane-updates-11-28"

  eks_cluster_id       = module.eks_blueprints.eks_cluster_id
  #eks_cluster_endpoint = module.eks_blueprints.eks_cluster_endpoint
  #eks_oidc_provider    = module.eks_blueprints.oidc_provider
  #eks_cluster_version  = module.eks_blueprints.eks_cluster_version

  # Wait on the data plane to be up
  #data_plane_wait_arn = module.eks_blueprints.managed_node_group_arn[0]

  # Deploy Crossplane
  enable_crossplane = true

  #---------------------------------------------------------
  # Crossplane AWS Provider deployment
  #   Creates ProviderConfig name as "default"
  #---------------------------------------------------------
  crossplane_aws_provider = local.crossplane_aws_provider

  #---------------------------------------------------------
  # Crossplane Kubernetes Provider deployment
  #   Creates ProviderConfig name as "default"
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

  create_igw           = true

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
