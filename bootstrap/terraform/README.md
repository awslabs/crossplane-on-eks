# Crossplane bootstrap with Terraform
This example deploys the following components
- Creates a new VPC, 3 Private Subnets and 3 Public Subnets, Internet gateway for Public Subnets and NAT Gateway for Private Subnets
- Creates EKS Cluster Control plane with one Managed node group
- Karpenter Cluster Autoscaler
- Crossplane Add-on 
- AWS Provider for Crossplane

## How to Deploy
### Prerequisites:
Ensure that you have installed the following tools in your Mac or Windows Laptop before start working with this module and run Terraform Plan and Apply
1. [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
3. [Kubectl](https://Kubernetes.io/docs/tasks/tools/)
4. [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

### Deployment Steps
#### Step1: Clone the repo using the command below

```shell script
git clone https://github.com/aws-samples/amazon-crossplane-blueprints.git
```

#### Step2: Run Terraform INIT
Initialize a working directory with configuration files

```shell script
cd bootstrap/terraform/
terraform init
```

#### Step3: Run Terraform PLAN
Verify the resources created by this execution

```shell script
export AWS_REGION=<ENTER YOUR REGION>   # Select your own region
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
#### Step7: List all the pods running in `kube-system` namespace
```shell script
kubectl get pods -n kube-system
```

### Deploy S3 bucket using Crossplane

- Edit the `s3.yaml` to update the new bucket name

```shell script
vi ~/bootstrap/terraform/examples/s3.yaml
```
Enter the new bucket name and region in YAML file
Save the file using :wq!

- Use `kubectl` to apply the `s3.yaml`

```shell script
cd ~/bootstrap/terraform/examples/
kubectl apply -f s3.yaml
```

- Login to AWS Console and verify the new S3 bucket


## How to Destroy
The following command destroys the resources created by `terraform apply`

Step1: Delete resources created by Crossplane

Step2: Terraform Destroy

```shell script
cd bootstrap/terraform/
terraform destroy --auto-approve
```
