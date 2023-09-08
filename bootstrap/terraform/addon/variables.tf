variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

################################################################################
# Crossplane
################################################################################

variable "enable_crossplane" {
  description = "Enable Crossplane Kubernetes add-on"
  type        = bool
  default     = false
}

variable "crossplane" {
  description = "Crossplane add-on configuration values"
  type        = any
  default     = {}
}

