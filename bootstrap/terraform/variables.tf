# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

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
