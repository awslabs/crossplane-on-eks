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
  default     = true
}

variable "ecr_account_id" {
  type        = string
  description = "ECR repository AWS Account ID"
  default     = ""
}

variable "ecr_region" {
  type        = string
  description = "ECR repository AWS Region"
  default     = ""
}

variable "docker_secret" {
  type = object({
    username    = string
    accessToken = string
  })
  default = {
    username    = ""
    accessToken = ""
  }
  sensitive = true
  validation {
    condition = !(var.docker_secret.username == "" || var.docker_secret.accessToken == "")
    error_message = <<EOT
Both username and accessToken must be provided.
Use the following command to pass these variables:
  terraform plan -var='docker_secret={"username":"your_username", "accessToken":"your_access_token"}'
EOT
  }
}