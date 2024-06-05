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
  default     = "crossplane-blueprints-fully-private"
}

variable "cluster_version" {
  type        = string
  description = "Kubernetes Version"
  default     = "1.29"
}

variable "capacity_type" {
  type        = string
  description = "Capacity SPOT or ON_DEMAND"
  default     = "SPOT"
}

variable "enable_upjet_aws_provider" {
  type        = bool
  description = "Installs the upjet aws provider"
  default     = true
}

variable "enable_aws_provider" {
  type        = bool
  description = "Installs the contrib aws provider"
  default     = false
}

variable "enable_kubernetes_provider" {
  type        = bool
  description = "Installs the kubernetes provider"
  default     = true
}

variable "enable_helm_provider" {
  type        = bool
  description = "Installs the helm provider"
  default     = false
}

variable "ecr_aws_account_id" {
  type        = bool
  description = "ECR repository AWS Account ID"
  default     = false
}

variable "ecr_aws_region" {
  type        = bool
  description = "ECR repository AWS Region"
  default     = false
}
