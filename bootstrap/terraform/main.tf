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
    args        = ["eks", "get-token", "--cluster-name", local.name, "--region", local.region]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", local.name, "--region", local.region]
      command     = "aws"
    }
  }
}

provider "kubectl" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", local.name, "--region", local.region]
    command     = "aws"
  }
  load_config_file  = false
  apply_retry_count = 15
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
  version = "~> 5.30"

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
  version = "~> 20.0"

  cluster_name                   = local.name
  cluster_version                = local.cluster_version
  cluster_endpoint_public_access = true
  kms_key_enable_default_policy  = true

  # Give the Terraform identity admin access to the cluster
  # which will allow resources to be deployed into the cluster
  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_addons = {
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_driver_irsa.iam_role_arn
    }
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      before_compute = true # Ensure the addon is configured before compute resources are created
      most_recent    = true
    }
  }

  # for production cluster, add a node group for add-ons that should not be inerrupted such as coredns
  eks_managed_node_groups = {
    initial = {
      instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
      capacity_type  = var.capacity_type # defaults to SPOT
      min_size       = 1
      max_size       = 5
      desired_size   = 3
      subnet_ids     = module.vpc.private_subnets
    }
  }

  tags = local.tags

  depends_on = [module.vpc]
}

#---------------------------------------------------------------
# EKS Addons
#---------------------------------------------------------------

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.16"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  enable_argocd = true
  argocd = {
    namespace     = "argocd"
    chart_version = "7.1.0" # ArgoCD v2.11.2
    values = [
      templatefile("${path.module}/values/argocd.yaml", {
        crossplane_aws_provider_enable        = local.aws_provider.enable
        crossplane_upjet_aws_provider_enable  = local.upjet_aws_provider.enable
        crossplane_kubernetes_provider_enable = local.kubernetes_provider.enable
    })]
  }

  enable_metrics_server               = true
  enable_aws_load_balancer_controller = true

  enable_kube_prometheus_stack = true
  kube_prometheus_stack = {
    timeout = "600"
    values  = [file("${path.module}/values/prometheus.yaml")]
  }

  depends_on = [module.eks.cluster_addons]
}

resource "time_sleep" "addons_wait_60_seconds" {
  create_duration = "60s"
  depends_on      = [module.eks_blueprints_addons]
}

#---------------------------------------------------------------
# Gatekeeper
#---------------------------------------------------------------
module "gatekeeper" {
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.1.1"

  name             = "gatekeeper"
  description      = "A Helm chart to deploy gatekeeper project"
  namespace        = "gatekeeper-system"
  create_namespace = true
  chart            = "gatekeeper"
  chart_version    = "3.16.3"
  repository       = "https://open-policy-agent.github.io/gatekeeper/charts"

  depends_on = [time_sleep.addons_wait_60_seconds]
}

#---------------------------------------------------------------
# Crossplane
#---------------------------------------------------------------
module "crossplane" {
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.1.1"

  name             = "crossplane"
  description      = "A Helm chart to deploy crossplane project"
  namespace        = "crossplane-system"
  create_namespace = true
  chart            = "crossplane"
  chart_version    = "1.16.0"
  repository       = "https://charts.crossplane.io/stable/"
  timeout          = "600"
  values           = [file("${path.module}/values/crossplane.yaml")]

  depends_on = [time_sleep.addons_wait_60_seconds]
}

resource "kubectl_manifest" "environmentconfig" {
  yaml_body = templatefile("${path.module}/config/environmentconfig.yaml", {
    awsAccountID = data.aws_caller_identity.current.account_id
    eksOIDC      = module.eks.oidc_provider
    vpcID        = module.vpc.vpc_id
  })

  depends_on = [module.crossplane]
}

#---------------------------------------------------------------
# Crossplane Providers Settings
#---------------------------------------------------------------
locals {
  crossplane_namespace = "crossplane-system"

  upjet_aws_provider = {
    enable               = var.enable_upjet_aws_provider # defaults to true
    version              = "v1.6.0"
    runtime_config       = "upjet-aws-runtime-config"
    provider_config_name = "aws-provider-config" #this is the providerConfigName used in all the examples in this repo
    families = [
      "dynamodb",
      "ec2",
      "elasticache",
      "iam",
      "kms",
      "lambda",
      "rds",
      "s3",
      "sns",
      "sqs",
      "vpc",
      "apigateway",
      "cloudwatch",
      "cloudwatchlogs"
    ]
  }

  aws_provider = {
    enable               = var.enable_aws_provider # defaults to false
    version              = "v0.48.0"
    name                 = "aws-provider"
    runtime_config       = "aws-runtime-config"
    provider_config_name = "aws-provider-config" #this is the providerConfigName used in all the examples in this repo
  }

  kubernetes_provider = {
    enable               = var.enable_kubernetes_provider # defaults to true
    version              = "v0.13.0"
    service_account      = "kubernetes-provider"
    name                 = "kubernetes-provider"
    runtime_config       = "kubernetes-runtime-config"
    provider_config_name = "default"
    cluster_role         = "cluster-admin"
  }

  helm_provider = {
    enable               = var.enable_helm_provider # defaults to true
    version              = "v0.18.1"
    service_account      = "helm-provider"
    name                 = "helm-provider"
    runtime_config       = "helm-runtime-config"
    provider_config_name = "default"
    cluster_role         = "cluster-admin"
  }

}

#---------------------------------------------------------------
# Crossplane Upjet AWS Provider
#---------------------------------------------------------------
module "upjet_irsa_aws" {
  count   = local.upjet_aws_provider.enable == true ? 1 : 0
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.30"

  role_name_prefix           = "${local.name}-upjet-aws-"
  assume_role_condition_test = "StringLike"

  role_policy_arns = {
    policy = "arn:aws:iam::aws:policy/AdministratorAccess"
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${local.crossplane_namespace}:provider-upjet-aws-*"]
    }
  }

  tags = local.tags

  depends_on = [module.crossplane]
}

resource "kubectl_manifest" "upjet_aws_runtime_config" {
  count = local.upjet_aws_provider.enable == true ? 1 : 0
  yaml_body = templatefile("${path.module}/providers/upjet-aws/runtime-config.yaml", {
    iam-role-arn   = module.upjet_irsa_aws[0].iam_role_arn
    runtime-config = local.upjet_aws_provider.runtime_config
  })

  depends_on = [module.crossplane]
}

resource "kubectl_manifest" "upjet_aws_provider" {
  for_each = local.upjet_aws_provider.enable ? toset(local.upjet_aws_provider.families) : toset([])
  yaml_body = templatefile("${path.module}/providers/upjet-aws/provider.yaml", {
    family         = each.key
    version        = local.upjet_aws_provider.version
    runtime-config = local.upjet_aws_provider.runtime_config
  })

  depends_on = [kubectl_manifest.upjet_aws_runtime_config, module.crossplane]
}

# Wait for the Upbound AWS Provider CRDs to be fully created before initiating upjet_aws_provider_config
resource "time_sleep" "upjet_wait_60_seconds" {
  count           = local.upjet_aws_provider.enable == true ? 1 : 0
  create_duration = "60s"

  depends_on = [kubectl_manifest.upjet_aws_provider, module.crossplane]
}

resource "kubectl_manifest" "upjet_aws_provider_config" {
  count = local.upjet_aws_provider.enable == true ? 1 : 0
  yaml_body = templatefile("${path.module}/providers/upjet-aws/provider-config.yaml", {
    provider-config-name = local.upjet_aws_provider.provider_config_name
  })

  depends_on = [kubectl_manifest.upjet_aws_provider, time_sleep.upjet_wait_60_seconds, module.crossplane]
}

#---------------------------------------------------------------
# Crossplane AWS Provider
#---------------------------------------------------------------
module "irsa_aws_provider" {
  count   = local.aws_provider.enable == true ? 1 : 0
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.30"

  role_name_prefix           = "${local.name}-aws-provider-"
  assume_role_condition_test = "StringLike"

  role_policy_arns = {
    policy = "arn:aws:iam::aws:policy/AdministratorAccess"
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${local.crossplane_namespace}:aws-provider-*"]
    }
  }

  tags = local.tags

  depends_on = [module.crossplane]
}

resource "kubectl_manifest" "aws_runtime_config" {
  count = local.aws_provider.enable == true ? 1 : 0
  yaml_body = templatefile("${path.module}/providers/aws/runtime-config.yaml", {
    iam-role-arn   = module.irsa_aws_provider[0].iam_role_arn
    runtime-config = local.aws_provider.runtime_config
  })

  depends_on = [module.crossplane]
}

resource "kubectl_manifest" "aws_provider" {
  count = local.aws_provider.enable == true ? 1 : 0
  yaml_body = templatefile("${path.module}/providers/aws/provider.yaml", {
    aws-provider-name = local.aws_provider.name
    version           = local.aws_provider.version
    runtime-config    = local.aws_provider.runtime_config
  })

  depends_on = [kubectl_manifest.aws_runtime_config, module.crossplane]
}

# Wait for the Upbound AWS Provider CRDs to be fully created before initiating aws_provider_config
resource "time_sleep" "aws_wait_60_seconds" {
  count           = local.aws_provider.enable == true ? 1 : 0
  create_duration = "60s"

  depends_on = [kubectl_manifest.aws_provider, module.crossplane]
}

resource "kubectl_manifest" "aws_provider_config" {
  count = local.aws_provider.enable == true ? 1 : 0
  yaml_body = templatefile("${path.module}/providers/aws/provider-config.yaml", {
    provider-config-name = local.aws_provider.provider_config_name
  })

  depends_on = [kubectl_manifest.aws_provider, time_sleep.aws_wait_60_seconds, module.crossplane]
}

#---------------------------------------------------------------
# Crossplane Kubernetes Provider
#---------------------------------------------------------------
resource "kubernetes_service_account_v1" "kubernetes_runtime" {
  count = local.kubernetes_provider.enable == true ? 1 : 0
  metadata {
    name      = local.kubernetes_provider.service_account
    namespace = local.crossplane_namespace
  }

  depends_on = [module.crossplane]
}

resource "kubectl_manifest" "kubernetes_provider_clusterolebinding" {
  count = local.kubernetes_provider.enable == true ? 1 : 0
  yaml_body = templatefile("${path.module}/providers/kubernetes/clusterrolebinding.yaml", {
    namespace    = local.crossplane_namespace
    cluster-role = local.kubernetes_provider.cluster_role
    sa-name      = kubernetes_service_account_v1.kubernetes_runtime[0].metadata[0].name
  })

  depends_on = [kubernetes_service_account_v1.kubernetes_runtime, module.crossplane]
}

resource "kubectl_manifest" "kubernetes_runtime_config" {
  count = local.kubernetes_provider.enable == true ? 1 : 0
  yaml_body = templatefile("${path.module}/providers/kubernetes/runtime-config.yaml", {
    sa-name        = kubernetes_service_account_v1.kubernetes_runtime[0].metadata[0].name
    runtime-config = local.kubernetes_provider.runtime_config
  })

  depends_on = [kubectl_manifest.kubernetes_provider_clusterolebinding, module.crossplane]
}

resource "kubectl_manifest" "kubernetes_provider" {
  count = local.kubernetes_provider.enable == true ? 1 : 0
  yaml_body = templatefile("${path.module}/providers/kubernetes/provider.yaml", {
    version                  = local.kubernetes_provider.version
    kubernetes-provider-name = local.kubernetes_provider.name
    runtime-config           = local.kubernetes_provider.runtime_config
  })

  depends_on = [module.crossplane, kubectl_manifest.kubernetes_runtime_config]
}

# Wait for the AWS Provider CRDs to be fully created before initiating provider_config deployment
resource "time_sleep" "wait_60_seconds_kubernetes" {
  create_duration = "60s"

  depends_on = [module.crossplane, kubectl_manifest.kubernetes_provider]
}

resource "kubectl_manifest" "kubernetes_provider_config" {
  count = local.kubernetes_provider.enable == true ? 1 : 0
  yaml_body = templatefile("${path.module}/providers/kubernetes/provider-config.yaml", {
    provider-config-name = local.kubernetes_provider.provider_config_name
  })

  depends_on = [module.crossplane, kubectl_manifest.kubernetes_provider, time_sleep.wait_60_seconds_kubernetes]
}

#---------------------------------------------------------------
# Crossplane Helm Provider
#---------------------------------------------------------------
resource "kubernetes_service_account_v1" "helm_runtime" {
  count = local.helm_provider.enable == true ? 1 : 0
  metadata {
    name      = local.helm_provider.service_account
    namespace = local.crossplane_namespace
  }

  depends_on = [module.crossplane]
}

resource "kubectl_manifest" "helm_runtime_clusterolebinding" {
  count = local.helm_provider.enable == true ? 1 : 0
  yaml_body = templatefile("${path.module}/providers/helm/clusterrolebinding.yaml", {
    namespace    = local.crossplane_namespace
    cluster-role = local.helm_provider.cluster_role
    sa-name      = kubernetes_service_account_v1.helm_runtime[0].metadata[0].name
  })

  depends_on = [kubernetes_service_account_v1.helm_runtime, module.crossplane]
}

resource "kubectl_manifest" "helm_runtime_config" {
  count = local.helm_provider.enable == true ? 1 : 0
  yaml_body = templatefile("${path.module}/providers/helm/runtime-config.yaml", {
    sa-name        = kubernetes_service_account_v1.helm_runtime[0].metadata[0].name
    runtime-config = local.helm_provider.runtime_config
  })

  depends_on = [kubectl_manifest.helm_runtime_clusterolebinding, module.crossplane]
}

resource "kubectl_manifest" "helm_provider" {
  count = local.helm_provider.enable == true ? 1 : 0
  yaml_body = templatefile("${path.module}/providers/helm/provider.yaml", {
    version            = local.helm_provider.version
    helm-provider-name = local.helm_provider.name
    runtime-config     = local.helm_provider.runtime_config
  })

  depends_on = [kubectl_manifest.helm_runtime_config, module.crossplane]
}

# Wait for the AWS Provider CRDs to be fully created before initiating provider_config deployment
resource "time_sleep" "wait_60_seconds_helm" {
  create_duration = "60s"

  depends_on = [kubectl_manifest.helm_provider, module.crossplane]
}

resource "kubectl_manifest" "helm_provider_config" {
  count = local.helm_provider.enable == true ? 1 : 0
  yaml_body = templatefile("${path.module}/providers/helm/provider-config.yaml", {
    provider-config-name = local.helm_provider.provider_config_name
  })

  depends_on = [kubectl_manifest.helm_provider, time_sleep.wait_60_seconds_helm, module.crossplane]
}

#---------------------------------------------------------------
# Supporting Resources
#---------------------------------------------------------------

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  manage_default_vpc = true

  name = local.vpc_name
  cidr = local.vpc_cidr

  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}
