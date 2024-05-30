terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.34"
    }

    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.30"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.13"
    }
  }

  # ##  Used for end-to-end testing on project; update to suit your needs
  # backend "s3" {
  #   bucket = "terraform-crossplane-on-eks-github-actions-state"
  #   region = "us-east-1"
  #   key    = "e2e/bootstrap/terraform/terraform.tfstate"
  # }
}
