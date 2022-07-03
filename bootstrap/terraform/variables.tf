# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "EKS Cluster Name and the VPC name"
  type        = string
  default     = "aws-preprod-cplane"
}

variable "cluster_version" {
  type        = string
  description = "Kubernetes Version"
  default     = "1.22"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR range"
  default     = "10.2.0.0/16"
}

variable "tags" {
  description = "Default tags"
  default     = {}
  type        = map(string)
}
