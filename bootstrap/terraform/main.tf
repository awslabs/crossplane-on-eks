# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", local.name, "--region", var.region]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", local.name, "--region", var.region]
      command     = "aws"
    }
  }
}

provider "kubectl" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", local.name, "--region", var.region]
    command     = "aws"
  }
  load_config_file       = false
  apply_retry_count      = 15
}

data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}

locals {
  name   = var.name
  region = var.region

  cluster_version = var.cluster_version
  cluster_name    = local.name

  vpc_name = local.name
  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/awslabs/crossplane-on-eks"
  }
}

#---------------------------------------------------------------
# EBS CSI Driver Role
#---------------------------------------------------------------

module "ebs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.14"

  role_name = "${local.name}-ebs-csi-driver"

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = local.tags
}

#---------------------------------------------------------------
# EKS Cluster
#---------------------------------------------------------------

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.10"

  cluster_name                   = local.name
  cluster_version                = local.cluster_version
  cluster_endpoint_public_access = true

  cluster_addons = {
    aws-ebs-csi-driver = {
      service_account_role_arn = module.ebs_csi_driver_irsa.iam_role_arn
      most_recent              = true
    }
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    initial = {
      instance_types  = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
      capacity_type   = "SPOT"
      min_size        = 1
      max_size        = 5
      desired_size    = 3
      subnet_ids      = module.vpc.private_subnets
    }
  }

  tags = local.tags
}

#---------------------------------------------------------------
# EKS Addons
#---------------------------------------------------------------

module "eks_blueprints_kubernetes_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints-addons"

  cluster_name          = module.eks.cluster_name
  cluster_endpoint      = module.eks.cluster_endpoint
  cluster_version       = module.eks.cluster_version
  oidc_provider         = module.eks.oidc_provider
  oidc_provider_arn     = module.eks.oidc_provider_arn
  enable_karpenter      = true
  enable_metrics_server = true
  enable_prometheus     = true

  depends_on = [module.eks.managed_node_groups]
}

module "eks_blueprints_crossplane_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.27.0"

  eks_cluster_id = module.eks.cluster_name
  # Deploy Crossplane
  # Default helm chart and providers values set at https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/modules/kubernetes-addons/crossplane/locals.tf
  enable_crossplane = true
  crossplane_helm_config = {
    version = "1.11.2"
    values = [yamlencode({
      args    = ["--enable-environment-configs"]
      metrics = {
        enabled = true
      }
      resourcesCrossplane = {
        limits = {
          cpu = "1"
          memory = "2Gi"
        }
        requests = {
          cpu = "100m"
          memory = "1Gi"
        }
      }
      resourcesRBACManager = {
        limits = {
          cpu = "500m"
          memory = "1Gi"
        }
        requests = {
          cpu = "100m"
          memory = "512Mi"
        }
      }
    })]
  }
  #---------------------------------------------------------
  # Crossplane community AWS Provider deployment
  #---------------------------------------------------------
  crossplane_aws_provider = {
    # !NOTE!: only enable one AWS provider at a time
    enable          = true
    provider_config = "aws-provider-config"
    provider_aws_version = "v0.38.0"
    # to override the default irsa policy:
    # additional_irsa_policies = ["arn:aws:iam::aws:policy/AmazonS3FullAccess"]
  }

  #---------------------------------------------------------
  # Crossplane Upbound AWS Provider deployment
  #---------------------------------------------------------
  crossplane_upbound_aws_provider = {
    # !NOTE!: only enable one AWS provider at a time
    enable          = true
    provider_config = "aws-provider-config"
    provider_aws_version = "v0.32.1"
    # to override the default irsa policy:
    # additional_irsa_policies = ["arn:aws:iam::aws:policy/AmazonS3FullAccess"]
  }

  #---------------------------------------------------------
  # Crossplane Kubernetes Provider deployment
  #---------------------------------------------------------
  crossplane_kubernetes_provider = {
    enable = true
    provider_kubernetes_version = "v0.7.0"
  }

  #---------------------------------------------------------
  # Crossplane Helm Provider deployment
  #---------------------------------------------------------
  crossplane_helm_provider = {
    enable = true
    provider_helm_version = "v0.14.0"
  }

  depends_on = [module.eks.managed_node_groups, module.eks_blueprints_kubernetes_addons]
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
