# Getting Started

This getting started guide will help you bootstrap your first cluster using Crossplane Blueprints.

## Prerequisites

Ensure that you have installed the following tools locally:

- [awscli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- [kubectl](https://Kubernetes.io/docs/tasks/tools/)
- [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Deploy

### eksctl

1. TBD

### terraform

1. For consuming Crossplane Blueprints, please see the [Getting Started](https://awslabs.github.io/crossplane-on-eks/getting-started/) section. For exploring and trying out the patterns provided, please clone the project locally to quickly get up and running with a pattern. After cloning the project locally, `cd` into the pattern directory of your choice.

2. To provision the pattern, the typical steps of execution are as follows:

    ```sh
    terraform init
    terraform apply -target="module.vpc" -auto-approve
    terraform apply -target="module.eks" -auto-approve
    terraform apply -target="module.eks_blueprints_addons" -auto-approve
    terraform apply -target="module.crossplane" -auto-approve
    terraform apply -auto-approve
    ```

3. Once all of the resources have successfully been provisioned, the following command can be used to update the `kubeconfig`
on your local machine and allow you to interact with your EKS Cluster using `kubectl`.

    ```sh
    aws eks --region <REGION> update-kubeconfig --name <CLUSTER_NAME> --alias <CLUSTER_NAME>
    ```

    !!! info "Terraform outputs"
        The examples will output the `aws eks update-kubeconfig ...` command as part of the Terraform apply output to simplify this process for users

4. Once you have updated your `kubeconfig`, you can verify that you are able to interact with your cluster by running the following command:

    ```sh
    kubectl get nodes
    ```

    This should return a list of the node(s) running in the cluster created. If any errors are encountered, please re-trace the steps above
    and consult the pattern's `README.md` for more details on any additional/specific steps that may be required.

## Destroy

To teardown and remove the resources created in the bootstrap, the typical steps of execution are as follows:

```sh
terraform destroy -target="module.crossplane" -auto-approve
terraform destroy -target="module.eks_blueprints_addons" -auto-approve
terraform destroy -target="module.eks" -auto-approve
terraform destroy -target="module.vpc" -auto-approve
terraform destroy -auto-approve
```

!!! danger "Resources created outside of Terraform"
    Some resources may have been created that Terraform is not aware of that will cause issues
    when attempting to clean up the pattern. Please see the `destroy.md` for more
    details.