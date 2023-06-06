#!/bin/bash

set -xe

terraform destroy -target="module.eks_blueprints_addons" -auto-approve
terraform destroy -target="module.eks_blueprints_crossplane_addons" -auto-approve
terraform destroy -target="module.eks" -auto-approve
terraform destroy -target="module.vpc" -auto-approve
terraform destroy -auto-approve
