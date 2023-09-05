# Steps to to deploy aurora rds cluster
This example deploys an aurora postgresql database cluster when applied the claim. Below are the steps to execute to
create a cluster and connect the cluster from a pod with an psql client.

## Pre-requisites
 - [Upbound AWS Provider Crossplane Blueprint Examples](../../README.md)


### create 2 role, one for RDS Monitoring and one for RDS Proxy

Create an IAM role and attach policy to the role (This role is required for aurora to perform monitoring)
    ```shell
    aws iam create-role --role-name aurora-monitoring \
                        --assume-role-policy-document '{
        "Version": "2012-10-17",
        "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
                "Principal":
                {
                "Service": "monitoring.rds.amazonaws.com"
                },
                "Action": "sts:AssumeRole"

        }
     ]
    }'
 (Attach the IAM role with AmazonRDSEnhancedMonitoringRole policy.)

    aws iam attach-role-policy --role-name aurora-monitoring \
                           --policy-arn arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole
    ```

  Create an 2nd IAM role and attach policy to the role (This role is required for aurora proxy to fetch db secrets from secret manager )

    ```shell
    aws iam create-role --role-name rds-proxy \
                        --assume-role-policy-document '{    
        "Version": "2012-10-17",
        "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
                "Principal":
                {
                "Service": "rds.amazonaws.com"
                },
                "Action": "sts:AssumeRole"

        }
    ]
    }'
    
    aws iam put-role-policy --role-name rds-proxy \
                            --policy-name rds-proxy-policy \  
                            --policy-document '{
                            "Version": "2012-10-17",
                            "Statement": [
                                {
                                    "Sid": "getsm",
                                    "Effect": "Allow",
                                    "Action": "secretsmanager:GetSecretValue",
                                    "Resource": "*"
                                },
                                {
                                    "Sid": "kmsdecrypt",
                                    "Effect": "Allow",
                                    "Action": "kms:Decrypt",
                                    "Resource": "*",
                                    "Condition": {
                                        "StringEquals": {
                                            "kms:ViaService": "secretsmanager.us-east-1.amazonaws.com"
                                        }
                                    }
                                }
                            ]
                        }'
  
    ```
  ### Provide value to the claim before applying.
     
     1. Open the claim and substitute the above 2 role arn with monitoringRoleArn and proxyRoleArn respectively.
     2. Make sure to go over the claim and substitute other field variable which has been mentioned e.g CIDR block
    
     Assuming that we have already applied the XRD and composition , if we run the below we can see a similar output as below
 ### Verify your XRDS and composition
    
    Verify the XRDs
    ```shell
    kubectl get xrds
    
    Expected output

    NAME                          ESTABLISHED   OFFERED   AGE
    xauroras.db.awsblueprint.io   True          True      5m
    
    ```

    Verify the Compositions
    
    ```shell
    
     kubectl get compositions
    
    Expected output. Note: the output might contain more compositions but these are the ones uses by the claim in the next step
       
    NAME                          XR-KIND   XR-APIVERSION                 AGE
    xauroras.db.awsblueprint.io   XAurora   db.awsblueprint.io/v1alpha1   5m

      ```

   if we have about same kind of output as above we can apply th claim: ( We are using a namespace as team-a in this example, if you want to change , please go ahead and create and update the same in the claim)

    ```shell
     cd ../composite-resources/database-examples/aurora
     k apply -f aurora-postgresql.yaml

    ```
    We can check the execution of claim by following command:

   ```shell
     
     k get Aurora -n team-a
     k describe Aurora -n team-a

    ```
    (It should take about 15-20 min to provision the Aurora RDS cluster.)
    
    Below is the default behaviour of the resource which will be provisioned through the claim, just to mention all this default behaviour can be overridden through patching .

    1. It will create a 3 node cluster with 1 writer and 2 reader endpoint spread across 3 Azs by default.
    2. It will also create a proxy to connect to the aurora cluster.
    3. The management of database credential is done through the secret manager.
    4. The security group has 2 rules , one to allow the app to connect to the proxy and one within the security group
        where the proxy can connect to the database (Make sure you have provided the correct the CIDR at the claim which is the allow CIDR on the security group from app.)
    5. The Aurora DB has been configured with logging and monitoring.
 ```
 ### Steps to check the connectivity from a pod 

Create an  policy to allow the pod to connect to the Aurora Database
  
  ```shell
    aws iam create-role --role-name aurora-monitoring \
                        --assume-role-policy-document '{    
        "Version": "2012-10-17",
        "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
                Action": [
                    "rds-db:connect"
                ],
                "Resource": [
                    "arn:aws:rds-db:${REGION_NAME}>:${ACCOUNT_NUMBER}:dbuser:*/*"
                ]
            }
        ]
    }'
  ```
    
    Create a service account passing the above policy arn

    ```shell
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
    
    PROXY_TERGET-ENDPOINT=k get secrets aurora-cluster-secrets  -n team-a -o json | jq -r .data.proxyEndpoint | base64 --decode
    CLUSTER_USER_NAME=k get secrets aurora-cluster-secrets  -n team-a -o json | jq -r .data.clusterUsername | base64 --decode
    
    aws rds generate-db-auth-token \
    --hostname ${PROXY_TERGET-ENDPOINT}  \
    --port 5432 \
    --region us-east-1 \
    --username ${CLUSTER_USER_NAME}
    
  ```
   create the pod with pgsql client:

  ```shell
    pod.yaml
    =========
    apiVersion: v1
    kind: Pod
    metadata:
    name: postgres-client
    namespace: team-a
    spec:
    serviceAccountName: rds-access
    containers:
    - name: postgreclient
        image: postgres:latest
        command: ["sleep"]
        args: ["3600"]  # Sleep for 1 hour (3600 seconds)
        envFrom:
        - secretRef:
            name: aurora-cluster-secrets
    volumes:
        - name: secret-volume
        secret:
            secretName: aurora-cluster-secrets # This secret name can be changed in the claim
  ```

   Exec into the pod

   ```shell

    k exec -it postgres-client -n team-a  -- sh
   
   ```

   create a DB connection and provide the token which you generate earlier for password.

   ```shell
   
   psql -h ${PROXY_TERGET-ENDPOINT}  -U ${CLUSTER_USER_NAME} -d aurorapgsqldb -W

    Note : we are providing the name of the database in the claim as:  aurorapgsqldb
   ```
   Now we should be able to connect to the DB with psql client.
