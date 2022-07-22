# Overview

## Goals
In this doc, we will configure the following:
- A Vault server (in-cluster or outside cluster)
- A Crossplane installation with AWS provider on EKS
- Provision a S3 bucket through Crossplane.
- Publish bucket information as a Vault secret.
- Access the published information in Vault from a pod using Vault Agent Injector

## Prerequisites
Following command line tools:
- kubectl
- helm
- eksctl
- aws


Note:
- As of Crossplane 1.9.0, the support for external secret store is still in alpha state and may go under changes.
- This assumes a use case for single-cluster multi-tenant. However, the underlying concepts discussed here should be applicable to multi-cluster setup as well.
- This doc is based on the excellent [vault secret store guide](https://github.com/crossplane/crossplane/blob/master/docs/guides/vault-as-secret-store.md#prepare-vault) and [external vault configuration guide](https://learn.hashicorp.com/tutorials/vault/kubernetes-external-vault). Please check these guides out for more detailed information. 

# Procedure

## Provision a EKS cluster

```bash
# from this repository root
eksctl create cluster -f bootstrap/eksctl/eksctl.yaml
```

## Create a Vault service
You can create a vault service in the same cluster as Crossplane or create a service on a VM. 

### In-cluster
Follow: https://github.com/crossplane/crossplane/blob/master/docs/guides/vault-as-secret-store.md#prepare-vault

### On an external VM
This VM must be reachable by the Crossplane installation. If you are using an EC2 instance, routing, network ACL, and Security Groups must be configured to allow for traffic from Crossplane pod to the VM. 

Commands below assumes the VM is an Ubuntu instance. 

#### Install Vault
Run the following commands in your VM.
```bash
# install vault and enable the service
sudo apt update && sudo apt install vault
sudo systemctl enable vault.service

# create a configuration file for vault. NOTE: this creates a vault service with TLS disabled. 
# This is done to make the configuration step easy to follow only. TLS should be enabled for real workloads.
cat <<< "ui = true

storage "file" {
  path = "/opt/vault/data"
}

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_disable = 1
}" | sudo -u vault tee /etc/vault.d/vault.hcl > /dev/null

sudo systemctl start vault.service

export VAULT_ADDR='http://127.0.0.1:8200'
# This command will print out unseal keys and the root token.
vault operator init
vault operator unseal # do this three times. each time with a different unseal key.
vault secrets enable -path=secret kv-v2
vault auth enable kubernetes
```


Get the IP address of this instance. For an EC2 instance, it should be the private IP of the instance. For a simple EC2 instance:
```bash
aws ec2 describe-instances \
--filters Name=instance-id,Values=<INSERT_INSTANCE_ID_HERE> \
| jq ".Reservations[0].Instances[0].NetworkInterfaces[0].PrivateIpAddress"
```

#### Install Vault Agent Sidecar Injector
Rut the following commands from a place where you have access to your Kubernetes cluster, e.g. your laptop. The Vault Agent Sidecar injector looks for CREATE and UPDATE events, then it will inject vault secret into the containers. 

```bash
kubectl create ns vault-system
# install vault injector. be sure to use the IP address obtained above.
helm -n vault-system install vault hashicorp/vault \
    --set "injector.externalVaultAddr=http://<PRIVATE_IP_ADDRESS>:8200"

TOKEN_REVIEW_JWJ=$(kubectl -n vault-system get secret $(kubectl -n vault-system get secrets --output=json | jq -r '.items[].metadata | select(.name|startswith("vault-token-")).name') --output='go-template={{ .data.token }}' | base64 --decode)
KUBE_HOST=$(kubectl config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.server}')
KUBE_CA_CERT=$(kubectl config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.certificate-authority-data}' | base64 --decode)
ISSUER=$(kubectl get --raw /.well-known/openid-configuration | jq -r .issuer)
```

Configure Kubernetes authentication, policy, and role for Crossplane to use in your VM:

```bash
vault write auth/kubernetes/config \
     token_reviewer_jwt="$TOKEN_REVIEW_JWT" \
     kubernetes_host="$KUBE_HOST" \
     kubernetes_ca_cert="$KUBE_CA_CERT" \
     issuer=$ISSUER

vault policy write crossplane - <<EOF
path "secret/data/crossplane-system*" {
    capabilities = ["create", "read", "update", "delete"]
}
path "secret/metadata/crossplane-system*" {
    capabilities = ["create", "read", "update", "delete"]
}
EOF``

vault write auth/kubernetes/role/crossplane \
    bound_service_account_names="*" \
    bound_service_account_namespaces=crossplane-system \
    policies=crossplane \
    ttl=24h
```

## Configure Vault
For our test cases to work, we need to configure additional Vault policy and role. Run the following commands in your vault pod or VM.

```bash
# create policy and role for applications to use.
ACCESSOR=$(vault auth list | grep kubernetes | tr -s ' ' | cut -d ' ' -f3)

vault policy write k8s-application - << EOF
path "secret/data/crossplane-system/{{identity.entity.aliases.${ACCESSOR}.metadata.service_account_namespace}}/*" {
  capabilities = ["read", "list"]
}
path "secret/metadata/crossplane-system/{{identity.entity.aliases.${ACCESSOR}.metadata.service_account_namespace}}/*" {
  capabilities = ["read", "list"]
}
EOF

vault write auth/kubernetes/role/k8s-application \
    bound_service_account_names="*" \
    bound_service_account_namespaces="*" \
    policies=k8s-application \
    ttl=1h
```

## Install and configure Crossplane

Crossplane must be configured with external secret store support. In addition, the Crossplane pod must have access to the vault token.

```bash
kubectl create ns crossplane-system
helm upgrade --install crossplane crossplane-stable/crossplane --namespace crossplane-system \
  --version 1.9.0 \
  --set 'args={--enable-external-secret-stores}' \
  --set-string customAnnotations."vault\.hashicorp\.com/agent-inject"=true \
  --set-string customAnnotations."vault\.hashicorp\.com/agent-inject-token"=true \
  --set-string customAnnotations."vault\.hashicorp\.com/role"=crossplane \
  --set-string customAnnotations."vault\.hashicorp\.com/agent-run-as-user"=65532
```

Once Crossplane is installed, install its AWS provider. 

Update the [AWS provider YAML file](../bootstrap/eksctl/crossplane/aws-provider-vault-secret.yaml) with your role ARN, then execute the following commands.

```bash 
kubectl apply -f bootstrap/eksctl/crossplane/aws-provider-vault-secret.yaml
kubectl get ProviderRevision
# example output
# NAME                        HEALTHY   REVISION   IMAGE                             STATE    DEP-FOUND   DEP-INSTALLED   AGE
# provider-aws-a2e16ca2fc1a   True      1          crossplane/provider-aws:v0.29.0   Active                               23s
```

`StoreConfig` objects provides Crossplane and its providers information about how to connect to secret stores. These objects must be configured for external secret integrations to work.

Update the [store config YAML file](../bootstrap/eksctl/crossplane/store-config-vault.yaml) with your endpoint information. If you configured vault outside of the cluster, it should be the private IP address. e.g. `10.0.0.1:8200`

```bash
kubectl apply -f bootstrap/eksctl/crossplane/store-config-vault.yaml

echo "apiVersion: aws.crossplane.io/v1beta1
kind: ProviderConfig
metadata:
  name: application1-provider-config
spec:
  credentials:
    source: InjectedIdentity" | kubectl apply -f - 
```

This creates two configurations for secrets stores:
- A configuration named `in-cluster` for Crossplane (compositions). This tells Crossplane to store composition secrets in the same cluster as Kubernetes secrets.
- Another configuration named `vault` for AWS provider. This tells the provider to store secrets the vault instance under the `/secret/crossplane-system` namespace. To access the vault instance, a token is created by the sidecar at `/vault/secrets/token`. 

## Create compositions
Apply the S3 compositions:

```bash
kubectl apply -f compositions/aws-provider/s3
```

The composition that is of interest is `compositions/aws-provider/s3/multi-tenant.yaml`. This composition demonstrates the following:
- `ProviderConfig` selection based on the claim's namespace.
- Publishes bucket information to Kubernetes secrets and Vault.
- Published Vault secrets are created under the claim's namespace in Vault.

## Test compositions

Try creating a bucket claim in the default namespace

```bash
kubectl apply -f examples/aws-provider/composite-resources/s3/multi-tenant.yaml
```
Then inspect the events for the bucket:
```bash
kubectl describe bucket
# example events
# Events:
#  Type     Reason                   Age               From                                 Message
#  ----     ------                   ----              ----                                 -------
#  Warning  CannotConnectToProvider  1s (x5 over 14s)  managed/bucket.s3.aws.crossplane.io  cannot get referenced Provider: ProviderConfig.aws.crossplane.io "default-provider-config" not found
```
In the [claim file](../examples/aws-provider/composite-resources/s3/multi-tenant.yaml), we specify a provider config name. However, this is patched out to use the provider config with name `<NAMESPACE>-provider-config`. This is why the error message indicates provider config with name `default-provider-config` is not found. 

Since we created a provider config named `application1-provider-config`, we should be able to create a claim in namespace called application1. 

```bash
kubectl apply -n application1 examples/aws-provider/composite-resources/s3/multi-tenant.yaml

kubectl -n application1 get objectstorage
# NAME                      READY   CONNECTION-SECRET   AGE
# standard-object-storage   True                        22s
```

Once the claim reaches the ready state, you should be able to verify. Secret creation:

```bash
kubectl -n crossplane-system get secret `kubectl get xobjectstorage -o json | jq -r '.items[0].metadata.uid'` -o go-template='{{range $k,$v := .data}}{{printf "%s: " $k}}{{if not $v}}{{$v}}{{else}}{{$v | base64decode}}{{end}}{{"\n"}}{{end}}'
# example output
# bucket-name: standard-object-storage-qlgvz-hz2dn
# region: us-west-2
```

The same information should be available in Vault:

```bash
# in your vault installation
vault kv get secret/crossplane-system/application1/dev/bucket
# ==================== Secret Path ====================
# secret/data/crossplane-system/application1/dev/bucket
#
# ======= Metadata =======
# Key                Value
# ---                -----
# created_time       2022-07-22T20:51:27.852598176Z
# custom_metadata    map[awsblueprints.io/composition-name:s3bucket-multi-tenant.awsblueprints.io awsblueprints.io/environment:dev awsblueprints.io/provider:aws secret.crossplane.io/owner-uid:0c601153-358d-45e1-8e0a-0f34991bed82]
# deletion_time      n/a
# destroyed          false
# version            1
#
# ====== Data ======
# Key         Value
# ---         -----
# endpoint    standard-object-storage-4p2wr-lxb74
# region      us-west-2
```

## Test Applications

Vault sidecar injector can inject secrets into pods. Create an example pod that access the secret created by the sidecar

```bash
echo 'apiVersion: v1
kind: Pod
metadata:
  name: test-pod
  annotations:
    vault.hashicorp.com/agent-inject: "true"
    vault.hashicorp.com/role: "k8s-application"
    vault.hashicorp.com/agent-inject-secret-credentials.txt: "secret/crossplane-system/application1/dev/bucket"
spec:
  containers:
    - name: busybox
      image: busybox:1.28
      command:
        - sh
        - -c
        - echo "Hello there!" && cat /vault/secrets/credentials.txt  && sleep 3600' | kubectl apply -f - 
```

This will create an pod in the default namespace. However, the pod will not reach the ready state. Check the logs:

```bash
kubectl logs  test-pod vault-agent-init
# URL: GET http://192.168.67.77:8200/v1/secret/data/crossplane-system/application1/dev/bucket
# Code: 403. Errors:

# * 1 error occurred:
# 	* permission denied
```

This is because the pod is created in the default namespace and the Vault policy we configured earlier does not allow it to access secrets in another namespace. 

Try creating the pod in the correct namespace.

```
echo 'apiVersion: v1
kind: Pod
metadata:
  name: test-pod
  namespace: application1
  annotations:
    vault.hashicorp.com/agent-inject: "true"
    vault.hashicorp.com/role: "k8s-application"
    vault.hashicorp.com/agent-inject-secret-credentials.txt: "secret/crossplane-system/application1/dev/bucket"
spec:
  containers:
    - name: busybox
      image: busybox:1.28
      command:
        - sh
        - -c
        - echo "Hello there!" && cat /vault/secrets/credentials.txt  && sleep 3600' | kubectl apply -f - 
```
The pod should reach ready state. 

```bash
kubectl -n application1 logs test-pod busybox
# Hello there!
# data: map[endpoint:standard-object-storage-qlgvz-hz2dn region:us-west-2]
# metadata: map[created_time:2022-07-21T21:27:38.82988124Z custom_metadata:map[awsblueprints.io/composition-name:s3bucket-multi-tenant.awsblueprints.io awsblueprints.io/environment:dev awsblueprints.io/provider:aws secret.crossplane.io/owner-uid:5089919f-e80f-4889-80f4-c8e3cacd8fb7] deletion_time: destroyed:false version:1]
```
