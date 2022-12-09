# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "EKS Cluster Name and the VPC name"
  type        = string
  default     = "crossplane-blueprints"
}

variable "cluster_version" {
  type        = string
  description = "Kubernetes Version"
  default     = "1.24"
}

variable "crossplane_helm_config" {
  description = "Helm Configuration for Crossplane"
  type = any
  default = {
  #  name       = "crossplane"
  #  chart      = "crossplane"
  #  repository = "https://charts.crossplane.io/stable/"
    version    = "1.10.1"
  #  namespace  = "crossplane-system"
  #  values = [templatefile("${path.module}/values.yaml", {
  #    operating-system = "linux"
  #  })]
  }
}

# NOTE: Crossplane requires Admin like permissions to create and update resources similar to Terraform deploy role.
# This example config uses AdministratorAccess for demo purpose only, but you should select a policy with the minimum permissions required to provision your resources
variable "crossplane_aws_provider" {
  description = "AWS Provider config for Crossplane"
  type = any
  default = {
    enable                   = true
    provider_aws_version     = "v0.34.0"
    additional_irsa_policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  # name                     = "aws-provider"
  # service_account          = "aws-provider"
  # provider_config          = "default"
  # controller_config        = "aws-controller-config"
  }
}

variable "crossplane_kubernetes_provider" {
  description = "Kubernetes Provider config for Crossplane"
  type = any
  default = {
    enable                      = true
    provider_kubernetes_version = "v0.5.0"
  #  name                        = "kubernetes-provider"
  #  service_account             = "kubernetes-provider"
  #  provider_config             = "default"
  #  controller_config           = "kubernetes-controller-config"
  #  cluster_role                = "cluster-admin"
  }
}