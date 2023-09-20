# Steps to to deploy aurora rds cluster
This example deploys an Aurora PostgreSQL database cluster with Amazon RDS Proxy for Aurora.
Below are the steps to create a cluster and connect from a pod with an psql client.

## Pre-requisites
 - [Upbound AWS Provider Crossplane Blueprint Examples](../../README.md)

> [!NOTE]  
> aurora-monitoring and rds-proxy iam roles need to be created manually at this time but will be added to the composition, track progress in [this issue](https://github.com/awslabs/crossplane-on-eks/issues/144).
### Create 2 roles, one for RDS Monitoring and one for RDS Proxy

Create an IAM role and attach policy to the role (This role is required for aurora to perform monitoring)

```shell
# Assuming root directory.
cd ./examples/upbound-aws-provider/composite-resources/databases/aurora
```

    
```shell
aws iam create-role \
--role-name aurora-monitoring \
--assume-role-policy-document file://aurora-monitoring.json
 ```
 (Attach the IAM role with AmazonRDSEnhancedMonitoringRole policy.)

```shell
aws iam attach-role-policy \
--role-name aurora-monitoring \
--policy-arn arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole
```

Create second IAM role and attach policy to the role (This role is required for aurora proxy to fetch db secrets from secret manager )

```shell
aws iam create-role \
--role-name rds-proxy \
--assume-role-policy-document file://rds-proxy.json
```
 
 ```shell
CURRENT_REGION=<REGION_NAME> # replace <REGION_NAME> with current region name e.g us-east-1.
CLUSTER_NAME=<EKS_CLUSTER_NAME> # replace <EKS_CLUSTER_NAME> with eks cluster name.
ACCOUNT_NUM=$(aws sts get-caller-identity --query Account --output text)
```

```shell
envsubst <rds-proxy-policy.json -o rds-proxy-policy.json

aws iam put-role-policy \
--role-name rds-proxy \
--policy-name rds-proxy-policy \
--policy-document file://rds-proxy-policy.json
```
### Provide value to the claim before applying.
     
 1. Open the claim and substitute aurora-monitoring role arn with monitoringRoleArn and rds-proxy role arn with proxyRoleArn respectively.
 2. Make sure check the CIDR block for application and provide in the claim. This will used as the security group 
    ingress rule for proxy from application ( we can also provide the security group id instead of CIDR).    
    
### Deploy and verify XRD and composition

Deploy the xrd and composition for aurora
```shell
# Assuming root directory.
cd ../../../../../compositions/upbound-aws-provider/aurora
kubectl apply -k .
```

```shell
kubectl get xrds | grep xauroras.db.awsblueprint.io
```

Expected output:

```shell
NAME                          ESTABLISHED   OFFERED   AGE
xauroras.db.awsblueprint.io   True          True      5m
```

Verify the Compositions
    
 ```shell
kubectl get compositions | grep xauroras.db.awsblueprint.io 
```

Expected output:

```shell
NAME                          XR-KIND   XR-APIVERSION                 AGE
xauroras.db.awsblueprint.io   XAurora   db.awsblueprint.io/v1alpha1   5m
```

### Apply the Aurora claim

If the xrd and composition are  in ready state, you are ready to apply the claim. We are using the `team-a` namespace in this example. If you'd like to use your own namespace, be sure to update the namespace field.

 ```shell
cd ../../../examples/upbound-aws-provider/composite-resources/databases/aurora
kubectl apply -f aurora-postgresql.yaml
```

We can check the execution of claim by following command:

```shell
kubectl get Aurora -n team-a
kubectl describe Aurora -n team-a
```
It should take about 15-20 min to provision the Aurora RDS cluster.

```shell
# To check the status of the cluster.
kubectl get clusters.rds.aws.upbound.io
kubectl get clusterinstances.rds.aws.upbound.io

# to check the status of proxy
kubectl get proxies.rds.aws.upbound.io

# To check the status of security group
kubectl get securitygroup.ec2.aws.upbound.io
kubectl get securitygrouprules.ec2.aws.upbound.io

# To check the status of subnet group
kubectl get subnetgroups.rds.aws.upbound.io

# To check the status of subnet group
k get Aurora -n team-a

# you can use describe to get detail information of the particular resource.
```
Below is the default behaviour of the resource which will be provisioned through the claim, just to mention all this default behaviour can be overridden through patching .

 1. It will create a 3 node cluster with 1 writer and 2 reader endpoint spread across 3 Azs by default.
 2. It will also create a [RDS proxy](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/rds-proxy.html) to connect to the aurora cluster.
 3. The management of database credential is done through the secret manager.
 4. The security group has 2 rules , one to allow the app to connect to the proxy and one within the security group
     where the proxy can connect to the database (Make sure you have provided the correct the CIDR at the claim which is the allow CIDR on the security group from app.)
 5. The Aurora DB has been configured with logging and monitoring.

### Test - Steps to check the database connectivity from a pod
Create a  policy to allow the pod to connect to the Aurora Database
  
```shell
# provide the account number and region name to the policy document.
envsubst <rdsproxy-access.json -o rdsproxy-access.json

aws iam create-policy \
--policy-name rdsproxy-access \
--policy-document file://rdsproxy-access.json
```
Create a service account passing the above policy arn

```shell
POLICY_ARN=$(aws iam list-policies --query 'Policies[?PolicyName==`rdsproxy-access`].Arn' --output text)

eksctl create iamserviceaccount \
--name rds-access \
--namespace team-a \
--cluster ${CLUSTER_NAME} \
--attach-policy-arn ${POLICY_ARN} \
--approve \
-override-existing-serviceaccounts
``` 
Generate a DB token which can be used for password when asked

```shell
PROXY_TARGET_ENDPOINT=kubectl get secrets aurora-cluster-secrets  -n team-a -o json | jq -r '.data.proxyEndpoint' | base64 --decode
CLUSTER_USER_NAME=kubectl get secrets aurora-cluster-secrets  -n team-a -o json | jq -r '.data.clusterUsername' | base64 --decode


aws rds generate-db-auth-token \
--hostname ${PROXY_TARGET_ENDPOINT}  \
--port 5432 \
--region ${CURRENT_REGION} \
--username ${CLUSTER_USER_NAME}
```
create the pod with psql client:

```shell
kubectl apply -f psql-client-pod.yaml
```

Exec into the pod

```shell
kubectl exec -it postgres-client -n team-a  -- sh
```

create a DB connection and provide the token which you generate earlier for password.

```shell
psql -h $proxyEndpoint  -U $clusterUsername -d aurorapgsqldb -W
```
You should be able to connect to the db. Now lets check the list of default table
Note : we are providing the name of the database in the claim as:  aurorapgsqldb

```shell
\dt
```
We should be able to do the required database operation.


### Clean up:

First delete the psql client pod
```shell
kubectl delete -f psql-client-pod.yaml
```
Delete the PostgreSQL Database by deleting the claim
```shell
kubectl delete -f aurora-postgresql.yaml
```
Note: It will take around ~15-20 min delete the whole cluster


Delete the Roles created
```shell
# Delete the serviceaccount
eksctl delete iamserviceaccount --name rds-access --cluster ${CLUSTER_NAME} --namespace team-a

# delete the policy created for serviceaccount
aws iam delete-policy --policy-arn $(aws iam list-policies --query 'Policies[?PolicyName==`rdsproxy-access`].Arn' --output text)

# Delete the rds-proxy-policy attached to the role
aws iam delete-role-policy --policy-name rds-proxy-policy --role-name rds-proxy

# Delete the rds-proxy role
aws iam delete-role --role-name rds-proxy

# Delete the rds-proxy-policy attached to the role
aws iam detach-role-policy \
--role-name aurora-monitoring \
--policy-arn arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole

# Delete aurora-monitoring role
aws iam delete-role --role-name aurora-monitoring
``` 

Delete the composition and XRDs
```shell
cd ../composition/upbound-aws-provider/aurora
kubectl delete -f aurora.yaml
kubectl delete -f definition.yaml
```
