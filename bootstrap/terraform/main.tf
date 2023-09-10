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

  argocd_namespace = "argocd"

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
  version = "~> 19.13"

  cluster_name                   = local.name
  cluster_version                = local.cluster_version
  cluster_endpoint_public_access = true
  kms_key_enable_default_policy  = true

  cluster_addons = {
    aws-ebs-csi-driver = {
      service_account_role_arn = module.ebs_csi_driver_irsa.iam_role_arn
    }
    coredns =    {}
    kube-proxy = {}
    vpc-cni =    {}
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # for production cluster, add a node group for add-ons that should not be inerrupted such as coredns
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

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "0.2.0"

  cluster_name          = module.eks.cluster_name
  cluster_endpoint      = module.eks.cluster_endpoint
  cluster_version       = module.eks.cluster_version
  oidc_provider_arn     = module.eks.oidc_provider_arn
  enable_argocd         = true
  argocd = {
    namespace       = local.argocd_namespace
    chart_version   = "5.34.6" # ArgoCD v2.7.3
    values          = [
      templatefile("${path.module}/argocd-values.yaml", {
        crossplane_aws_provider_enable = local.aws_provider.enable
        crossplane_upbound_aws_provider_enable = local.upbound_aws_provider.enable
      })]
  }
  enable_karpenter                 = true
  enable_metrics_server            = true
  enable_kube_prometheus_stack     = true
  kube_prometheus_stack = {
    values = [yamlencode({
      prometheus = {
        service = {
          type = "LoadBalancer"
        }
      }
    })]
  }

  depends_on = [module.eks.eks_managed_node_groups]
}

#---------------------------------------------------------------
# Crossplane
#---------------------------------------------------------------
module "crossplane" {
  source = "./addon/"
  enable_crossplane = true
  crossplane = {
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

  depends_on = [module.eks.eks_managed_node_groups]
}

#---------------------------------------------------------------
# Crossplane Providers Settings
#---------------------------------------------------------------
locals {
  crossplane_namespace = "crossplane-system"
  crossplane_sa_prefix = "provider-aws-"
  
  upbound_aws_provider = {
    enable = true
    controller_config = "upbound-aws-controller-config"
    provider_config_name = "aws-provider-config"
    version = "v0.40.0"
    sa_prefix = "upbound-aws-provider-"
    families = [
      "dynamodb",
      "elasticache",
      "iam",
      "kms",
      "lambda",
      "rds",
      "s3",
      "sns",
      "sqs",
      "vpc"
    ]
  }

  aws_provider = {
    enable = false
  }

  kubernetes_provider = {
    enable                = true
    version               = "v0.9.0"
    service_account       = "kubernetes-provider"
    name                  = "kubernetes-provider"
    controller_config     = "kubernetes-controller-config"
    provider_config_name  = "default"
    cluster_role          = "cluster-admin"
  }

}

#---------------------------------------------------------------
# Crossplane Upbound AWS Provider
#---------------------------------------------------------------
module "upbound_irsa_aws" {
  count = local.upbound_aws_provider.enable == true ? 1 : 0
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.30"

  role_name_prefix = local.upbound_aws_provider.sa_prefix

  role_policy_arns = {
    policy = "arn:aws:iam::aws:policy/AdministratorAccess"
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${local.crossplane_namespace}:${local.upbound_aws_provider.sa_prefix}*"]
    }
  }

  tags = local.tags
}

resource "kubectl_manifest" "upbound_aws_controller_config" {
  count = local.upbound_aws_provider.enable == true ? 1 : 0
  yaml_body = templatefile("${path.module}/providers/aws-upbound/controller-config.yaml", {
    iam-role-arn          = module.upbound_irsa_aws[0].iam_role_arn
    controller-config = local.upbound_aws_provider.controller_config
  })

  depends_on = [module.crossplane]
}

resource "kubectl_manifest" "upbound_aws_provider" {
  for_each = local.upbound_aws_provider.enable ? toset(local.upbound_aws_provider.families) : toset([])
  yaml_body = templatefile("${path.module}/providers/aws-upbound/provider.yaml", {
    family            = each.key
    version           = local.upbound_aws_provider.version
    controller-config = local.upbound_aws_provider.controller_config
  })
  wait = true

  depends_on = [kubectl_manifest.upbound_aws_controller_config]
}

# Wait for the Upbound AWS Provider CRDs to be fully created before initiating upbound_aws_provider_config
resource "time_sleep" "upbound_wait_60_seconds" {
  count           = local.upbound_aws_provider.enable == true ? 1 : 0
  create_duration = "60s"

  depends_on = [kubectl_manifest.upbound_aws_provider]
}

resource "kubectl_manifest" "upbound_aws_provider_config" {
  count = local.upbound_aws_provider.enable == true ? 1 : 0
  yaml_body = templatefile("${path.module}/providers/aws-upbound/provider-config.yaml", {
    provider-config-name = local.upbound_aws_provider.provider_config_name
  })

  depends_on = [kubectl_manifest.upbound_aws_provider, time_sleep.upbound_wait_60_seconds]
}

#---------------------------------------------------------------
# Crossplane AWS Provider
#---------------------------------------------------------------

#---------------------------------------------------------------
# Crossplane Kubernetes Provider
#---------------------------------------------------------------
resource "kubernetes_service_account_v1" "kubernetes_controller" {
  count = local.kubernetes_provider.enable == true ? 1 : 0
  metadata {
    name      = local.kubernetes_provider.service_account
    namespace = local.crossplane_namespace
  }

  depends_on = [module.crossplane]
}

resource "kubectl_manifest" "kubernetes_controller_clusterolebinding" {
  count = local.kubernetes_provider.enable == true ? 1 : 0
  yaml_body = templatefile("${path.module}/providers/kubernetes/clusterrolebinding.yaml", {
    namespace      = local.crossplane_namespace
    cluster-role   = local.kubernetes_provider.cluster_role
    sa-name        = kubernetes_service_account_v1.kubernetes_controller[0].metadata[0].name
  })
  wait = true

  depends_on = [module.crossplane]
}

resource "kubectl_manifest" "kubernetes_controller_config" {
  count = local.kubernetes_provider.enable == true ? 1 : 0
  yaml_body = templatefile("${path.module}/providers/kubernetes/controller-config.yaml", {
    sa-name           = kubernetes_service_account_v1.kubernetes_controller[0].metadata[0].name
    controller-config = local.kubernetes_provider.controller_config
  })
  wait = true

  depends_on = [module.crossplane]
}

resource "kubectl_manifest" "kubernetes_provider" {
  count = local.kubernetes_provider.enable == true ? 1 : 0
  yaml_body = templatefile("${path.module}/providers/kubernetes/provider.yaml", {
    version                   = local.kubernetes_provider.version
    kubernetes-provider-name  = local.kubernetes_provider.name
    controller-config         = local.kubernetes_provider.controller_config
  })
  wait = true

  depends_on = [kubectl_manifest.kubernetes_controller_config]
}

# Wait for the AWS Provider CRDs to be fully created before initiating aws_provider_config deployment
resource "time_sleep" "wait_60_seconds_kubernetes" {
  create_duration = "60s"

  depends_on = [kubectl_manifest.kubernetes_provider]
}

resource "kubectl_manifest" "kubernetes_provider_config" {
  count = local.kubernetes_provider.enable == true ? 1 : 0
  yaml_body = templatefile("${path.module}/providers/kubernetes/provider-config.yaml", {
    provider-config-name = local.kubernetes_provider.provider_config_name
  })

  depends_on = [kubectl_manifest.kubernetes_provider, time_sleep.wait_60_seconds_kubernetes]
}

#---------------------------------------------------------------
# Crossplane Helm Provider
#---------------------------------------------------------------

#---------------------------------------------------------------
# Supporting Resources
#---------------------------------------------------------------

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.vpc_name
  cidr = local.vpc_cidr

  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]

  enable_nat_gateway   = true
  single_nat_gateway   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}
