# Crossplane Configuration

## Steps to build and deploy Crossplane Configuration packages

`vpc-composition.yaml` and `vpc-xrd.yaml` can be deployed using `kubectl apply`

Alternatively, you can use the following steps to package the composition and deploy

### Step1

- Create a `crossplane.yaml` file where Composition and CompositeResourceDefinition resource files are available


### Step2: Build Configuration file

```shell
kubectl crossplane build configuration
```


### Step3: Create ECR repo
- Create a private/public repo in ECR for configuration

- e.g., ECR repo name as `cplane-vpc-composition`

### Step4: Push Configuration to ECR

Push the Crossplane configuration package to ECR with version 1.0.0

```shell
kubectl crossplane push configuration public.ecr.aws/r1l5w1y9/cplane-vpc-composition:1.0.0
```

### Step5: Install Crossplane Configuration

```shell
 kubectl crossplane install configuration public.ecr.aws/r1l5w1y9/cplane-vpc-composition:1.0.0
```
### Step6: Verify Crossplane Configuration
- Verify the Crossplane Configuration is successfully installed

```shell
kubectl get configuration

```
    # Output
    NAME                              INSTALLED   HEALTHY   PACKAGE                                                                                               AGE
    r1l5w1y9-cplane-vpc-composition   True        True      public.ecr.aws/r1l5w1y9/cplane-vpc-composition:public.ecr.aws/r1l5w1y9/cplane-vpc-composition:1.0.0   40h

### Step7: Update Crossplane Configuration

```shell
kubectl get configuration  
```

    NAME                              INSTALLED   HEALTHY   PACKAGE                                                                                               AGE
    r1l5w1y9-cplane-vpc-composition   True        True      public.ecr.aws/r1l5w1y9/cplane-vpc-composition:public.ecr.aws/r1l5w1y9/cplane-vpc-composition:1.0.0   40h

```shell
# kubectl crossplane update configuration <name> <tag>

kubectl crossplane update configuration r1l5w1y9-cplane-vpc-composition public.ecr.aws/r1l5w1y9/cplane-vpc-composition:1.0.0

# configuration.pkg.crossplane.io/r1l5w1y9-cplane-vpc-composition updated

```
