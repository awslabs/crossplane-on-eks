# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.7.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.4.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.13.1"
    }
  }
  # Please note that this example is using the local state file you can always change this to remote state e.g., s3 bucket
  backend "local" {
    path = "local_tf_state/terraform-main.tfstate"
  }

  required_version = ">= 1.0.0"
}

data "aws_availability_zones" "available" {}

data "aws_eks_cluster" "cluster" {
  name = module.aws-eks-accelerator-for-terraform.eks_cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.aws-eks-accelerator-for-terraform.eks_cluster_id
}

data "kubectl_path_documents" "karpenter_provisioners" {
  pattern = "${path.module}/karpenter-provisioners/default-provisioner.yaml"
  vars = {
    azs = join(",",local.azs)
    iam-instance-profile-id = format("%s-%s", local.cluster_name, local.node_group_name)
    eks-cluster-id = local.cluster_name
  }
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
  apply_retry_count      = 15
}

#---------------------------------------------------------------
# Local variables for your deployment
#---------------------------------------------------------------
locals {
  tenant             = var.tenant         # AWS account name or unique id for tenant
  environment        = var.environment    # Environment area eg., preprod or prod
  zone               = var.zone           # Environment with in one sub_tenant or business unit
  kubernetes_version = var.kubernetes_version
  azs  = data.aws_availability_zones.available.names

  vpc_cidr     = var.vpc_cidr
  vpc_name     = join("-", [local.tenant, local.environment, local.zone, "vpc"])
  cluster_name = join("-", [local.tenant, local.environment, local.zone, "eks"])
  node_group_name = "mng-ondemand"

  terraform_version = "Terraform v1.0.1"
}

#---------------------------------------------------------------
# This aws_vpc module creates VPC, 3 Private Subnets, 3 Public Subnets, IGW, Single NAT gateway
# You can comment or remove module if you already have an existing VPC and Subnets. You must add public_subnet_tags, private_subnet_tags to your existing VPC
#---------------------------------------------------------------
module "aws_vpc" {
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
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

#---------------------------------------------------------------
# This module deploys EKS Cluster with one Managed group
#---------------------------------------------------------------
module "aws-eks-accelerator-for-terraform" {
  source = "github.com/aws-samples/aws-eks-accelerator-for-terraform"

  tenant            = local.tenant
  environment       = local.environment
  zone              = local.zone
  terraform_version = local.terraform_version

  # EKS Cluster VPC and Subnet mandatory config
  vpc_id             = module.aws_vpc.vpc_id
  private_subnet_ids = module.aws_vpc.private_subnets

  # EKS CONTROL PLANE VARIABLES
  create_eks         = true
  kubernetes_version = local.kubernetes_version

  # EKS MANAGED NODE GROUPS
  managed_node_groups = {
    mg_4 = {
      node_group_name = local.node_group_name
      instance_types  = ["m5.xlarge"]
      min_size        = "2"
      subnet_ids      = module.aws_vpc.private_subnets
      additional_tags = {
        ExtraTag    = "m4-on-demand"
        Name        = "m4-on-demand"
        subnet_type = "private"
      }
    }
  }
}

#---------------------------------------------------------------
# This module deploys Kubernetes add-ons
#---------------------------------------------------------------
module "kubernetes-addons" {
  source         = "github.com/aws-samples/aws-eks-accelerator-for-terraform//modules/kubernetes-addons"
  eks_cluster_id = module.aws-eks-accelerator-for-terraform.eks_cluster_id

  # Deploy Karpenter Autoscaler
  enable_karpenter  = true

  # Deploy Crossplane
  enable_crossplane = true

  # Deploy Crossplane AWS Providers

  # NOTE: Crossplane requires Admin like permissions to create and update resources similar to Terraform deploy role.
  # This example config uses AdministratorAccess for demo purpose only, but you should select a policy with the minimum permissions required to provision your resources

  # Creates ProviderConfig -> aws-provider-config
  crossplane_aws_provider = {
    enable                   = true
    provider_aws_version     = "v0.24.1"
    additional_irsa_policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  }

  # Creates ProviderConfig -> jet-aws-provider-config
  crossplane_jet_aws_provider = {
    enable                   = true
    provider_aws_version     = "v0.4.1"
    additional_irsa_policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  }

}

# Deploying default provisioner for Karpenter autoscaler
resource "kubectl_manifest" "karpenter_provisioner" {
  for_each  = toset(data.kubectl_path_documents.karpenter_provisioners.documents)
  yaml_body = each.value

  depends_on = [module.kubernetes-addons]
}
