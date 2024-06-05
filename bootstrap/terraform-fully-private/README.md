# EKS Cluster bootstrap with Terraform for Crossplane

This example deploys the following components
- Creates a new sample VPC, Two Private Subnets and Two Public Subnets
- Creates Internet gateway for Public Subnets and NAT Gateway for Private Subnets
- Creates EKS Cluster Control plane with one managed node group
- Crossplane Add-on to EKS Cluster
- Upbound AWS Provider for Crossplane
- AWS Provider for Crossplane
- Kubernetes Provider for Crossplane
- Helm Provider for Crossplane

## Crossplane Deployment Design

```mermaid
graph TD;
    subgraph AWS Cloud
    id1(VPC)-->Private-Subnet1;
    id1(VPC)-->Private-Subnet2;
    id1(VPC)-->Public-Subnet1;
    id1(VPC)-->Public-Subnet2;
    Public-Subnet1-->InternetGateway
    Public-Subnet2-->InternetGateway
    Public-Subnet3-->InternetGateway
    Public-Subnet3-->Single-NATGateway
    Private-Subnet1-->EKS{{"EKS #9829;"}}
    Private-Subnet2-->EKS
    Private-Subnet3-->EKS
    EKS==>ManagedNodeGroup;
    ManagedNodeGroup-->|enable_crossplane=true|id2([Crossplane]);
    subgraph Kubernetes Add-ons
    id2([Crossplane])-.->|crossplane_aws_provider.enable=true|id3([AWS-Provider]);
    id2([Crossplane])-.->|crossplane_upbound_aws_provider.enable=true|id4([Upbound-AWS-Provider]);
    id2([Crossplane])-.->|crossplane_kubernetes_provider.enable=true|id5([Kubernetes-Provider]);
    id2([Crossplane])-.->|crossplane_helm_provider.enable=true|id6([Helm-Provider]);
    end
    end
```

## How to Deploy
### Prerequisites:
Ensure that you have installed the following tools in your Mac or Windows Laptop before start working with this module and run Terraform Plan and Apply
1. [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
1. [Kubectl](https://Kubernetes.io/docs/tasks/tools/)
1. [Terraform >=v1.0.0](https://learn.hashicorp.com/tutorials/terraform/install-cli)

### Troubleshooting
1. If `terraform apply` errors out after creating the cluster when trying to apply the helm charts, try running the command:
```shell
aws eks --region <enter-your-region> update-kubeconfig --name <cluster-name> --alias <cluster-name>
```
and executing terraform apply again.

1. Make sure you have upgraded to the latest version of AWS CLI. Make sure your AWS credentials are properly configured as well.

### Deployment Steps
#### Step1: Clone the repo using the command below

```shell script
git clone https://github.com/aws-samples/crossplane-aws-blueprints.git
```

> [!IMPORTANT]  
> The examples in this repository make use of one of the Crossplane AWS providers. 
For that reason `upbound_aws_provider.enable` is set to `true` and `aws_provider.enable` is set to `false`. If you use the examples for `aws_provider`, adjust the terraform [main.tf](https://github.com/awslabs/crossplane-on-eks/blob/main/bootstrap/terraform/main.tf) in order install only the necessary CRDs to the Kubernetes cluster.

#### Step2: Run Terraform INIT
Initialize a working directory with configuration files

```shell script
cd bootstrap/terraform/
terraform init
```

#### Step3: Run Terraform PLAN
Verify the resources created by this execution

```shell script
export TF_VAR_region=<ENTER YOUR REGION>   # Select your own region
terraform plan
```

#### Step4: Finally, Terraform APPLY
to create resources

```shell script
terraform apply
```

Enter `yes` to apply

### Configure `kubectl` and test cluster
EKS Cluster details can be extracted from terraform output or from AWS Console to get the name of cluster.
This following command used to update the `kubeconfig` in your local machine where you run kubectl commands to interact with your EKS Cluster.

#### Step5: Run `update-kubeconfig` command

`~/.kube/config` file gets updated with cluster details and certificate from the below command
```shell script
aws eks --region <enter-your-region> update-kubeconfig --name <cluster-name>
```
#### Step6: List all the worker nodes by running the command below
```shell script
kubectl get nodes
```
#### Step7: Verify the pods running in `crossplane-system` namespace
```shell script
kubectl get pods -n crossplane-system
```
#### Step8: Verify the names provider and provider configs
Run the following command to get the list of providers:
```shell script
kubectl get providers
```
The expected output looks like this:
```
NAME                  INSTALLED   HEALTHY   PACKAGE                                                         AGE
aws-provider          True        True      xpkg.upbound.io/crossplane-contrib/provider-aws:v0.36.0         36m
kubernetes-provider   True        True      xpkg.upbound.io/crossplane-contrib/provider-kubernetes:v0.6.0   36m
provider-helm         True        True      xpkg.upbound.io/crossplane-contrib/provider-helm:v0.13.0        36m
upbound-aws-provider  True        True      xpkg.upbound.io/upbound/provider-aws:v0.27.0                    36m
```
Run the following commands to get the list of provider configs:
```shell script
kubectl get provider
```
The expected output looks like this:
```
NAME                                                   AGE
providerconfig.aws.crossplane.io/aws-provider-config   36m

NAME                                        AGE
providerconfig.helm.crossplane.io/default   36m

NAME                                                                 AGE
providerconfig.kubernetes.crossplane.io/kubernetes-provider-config   36m
```

#### Step9: Access the ArgoCD UI
Get the load balancer url:
```
kubectl -n argocd get service argo-cd-argocd-server -o jsonpath="{.status.loadBalancer.ingress[*].hostname}{'\n'}"
```
Copy and paste the result in your browser.<br>
The initial username is `admin`. The password is autogenerated and you can get it by running the following command:
```
echo "$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)"
```

## Clean up
1. Delete resources created by Crossplane such as first Claims, then XRDs and Compositions.

1. Remove crossplane providers by running
```bash
terraform apply --var enable_upbound_aws_provider=false --var enable_aws_provider=false --var enable_kubernetes_provider=false --var enable_helm_provider=false
```

1. Run `kubectl get providers` to validate all providers were removed. If any left, remove using `kubectl delete providers <provider>`

1. Delete the EKS cluster and it's resources with the following command
```bash
./destroy.sh
```
