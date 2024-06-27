# Nested Compositions

Compositions can be nested within a composition. Take a look at the example-application defined in the `compositions/aws-provider/example-application` directory. The Composition contains Compositions defined in other directories and creates a DynamoDB table, IAM policies for the table, a Kubernetes service account, and a IAM role for service accounts (IRSA). This pattern is very powerful. It let you define your abstraction based on someone else's prior work.

An example yaml file to deploy this Composition is available at  `examples/aws-provider/composite-resources/example-application/example-application.yaml`.  

Install the AWS Compositions and XRDs following the instructions in [compositions/README.md](../../compositions/README.md)

Let’s take a look at how this example application can be deployed. 

```bash
kubectl create ns example-app
# namespace/example-app created

kubectl apply -f examples/aws-provider/composite-resources/example-application/example-application.yaml
# exampleapp.awsblueprints.io/example-application created
```

You can look at the example application object, but it doesn’t tell you much about what is happening. Let’s dig deeper. 
```bash
# kubectl get exampleapp -n example-app example-application -o=jsonpath='{.spec.resourceRef}'
{"apiVersion":"awsblueprints.io/v1alpha1","kind":"XExampleApp","name":"example-application-8x9fr"}
```
By looking at the spec.resourceRef field, you can see which cluster wide object this object created.
Let’s see what resources are created in the cluster wide object. 

```bash
# kubectl get XExampleApp example-application-8x9fr -o=jsonpath='{.spec.resourceRefs}' | jq
[
  {
    "apiVersion": "awsblueprints.io/v1alpha1",
    "kind": "XDynamoDBTable",
    "name": "example-application-8x9fr-svxxg"
  },
  {
    "apiVersion": "awsblueprints.io/v1alpha1",
    "kind": "XIAMPolicy",
    "name": "example-application-8x9fr-w9fgb"
  },
  {
    "apiVersion": "awsblueprints.io/v1alpha1",
    "kind": "XIAMPolicy",
    "name": "example-application-8x9fr-r5hzx"
  },
  {
    "apiVersion": "awsblueprints.io/v1alpha1",
    "kind": "XIRSA",
    "name": "example-application-8x9fr-r7dzn"
  },
  {
    "apiVersion": "kubernetes.crossplane.io/v1alpha1",
    "kind": "Object",
    "name": "example-application-8x9fr-bv7tl"
  }
]
```

We see that it has five sub objects. Notice the first object is the XDynamoDBTable kind. This application Composition contains the DynamoDB table Composition. In fact, four out of five sub objects in the above output are Compositions. 

Let’s take a look at the XIRSA object. As the name implies, this object is responsible for setting up EKS IRSA for the application pod to use. 

```bash

# kubectl get XIRSA example-application-8x9fr-r7dzn -o jsonpath='{.spec.resourceRefs}' | jq
[
  {
    "apiVersion": "iam.aws.crossplane.io/v1beta1",
    "kind": "Role",
    "name": "example-application-8x9fr-nwgbh"
  },
  {
    "apiVersion": "iam.aws.crossplane.io/v1beta1",
    "kind": "RolePolicyAttachment",
    "name": "example-application-8x9fr-n6g8q"
  },
  {
    "apiVersion": "iam.aws.crossplane.io/v1beta1",
    "kind": "RolePolicyAttachment",
    "name": "example-application-8x9fr-kzrsg"
  },
  {
    "apiVersion": "kubernetes.crossplane.io/v1alpha1",
    "kind": "Object",
    "name": "example-application-8x9fr-bzfr6"
  }
]
```

As you can see, it created an IAM Role and attached policies.  It also created a Kubernetes service account as represented by the last element. If you look at the created service account, it has the necessary properties for IRSA to function. 

```bash
# kubectl get sa -n example-app example-app -o yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::123456789:role/example-application-8x9fr-nwgbh
```
You can examine the IAM Role as well.

```bash
# aws iam list-roles --query 'Roles[?starts_with(RoleName, `example-application`) == `true`]'
[
    {
        "Path": "/",
        "RoleName": "example-application-8x9fr-nwgbh",
        "Arn": "arn:aws:iam::1234569091:role/example-application-8x9fr-nwgbh",
        "AssumeRolePolicyDocument": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {
                        "Federated": "arn:aws:iam::1234569091:oidc-provider/oidc.eks.us-west-2.amazonaws.com/id/12345919291AVBD"
                    },
                    "Action": "sts:AssumeRoleWithWebIdentity",
                    "Condition": {
                        "StringEquals": {
                            "oidc.eks.us-west-2.amazonaws.com/id/abcd12345:sub": "system:serviceaccount:example-app:example-app"
                        }
                    }
                }
            ]
        },
        "MaxSessionDuration": 3600
    }
] 
```
