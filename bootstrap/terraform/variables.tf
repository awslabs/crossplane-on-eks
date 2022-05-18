# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

variable "region" {
  description = "AWS region"
  type = string
}

variable "tenant" {
  type        = string
  description = "Account Name or unique account unique id e.g., apps or management or aws007"
  default = "aws"
}

variable "environment" {
  type        = string
  description = "Environment area, e.g. prod or preprod "
  default = "preprod"
}

variable "zone" {
  type        = string
  description = "zone, e.g. dev or qa or load or ops etc..."
  default = "cplane"
}

variable "cluster_version" {
  type        = string
  description = "Kubernetes Version"
  default     = "1.22"
}

variable "vpc_cidr" {
  type = string
  description = "VPC CIDR range"
  default = "10.2.0.0/16"
}
