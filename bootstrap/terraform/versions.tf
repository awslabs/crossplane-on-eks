terraform {
  required_version = "~> 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.19"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11.0"
    }
  }
}
