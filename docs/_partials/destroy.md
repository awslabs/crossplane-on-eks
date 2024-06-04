```sh
terraform destroy -target="module.crossplane" -auto-approve
terraform destroy -target="module.gatekeeper" -auto-approve
terraform destroy -target="module.eks_blueprints_addons" -auto-approve
terraform destroy -target="module.eks" -auto-approve
terraform destroy -target="module.vpc" -auto-approve
terraform destroy -auto-approve
```