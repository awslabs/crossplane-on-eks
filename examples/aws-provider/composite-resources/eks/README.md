# EKS Composition examples

## EKS with Cluster Autoscaler

_NOTE:_ Using Karpenter with the community provider is impossible due to its lack of support for necessary CloudWatch resources. See [this issue for more information](https://github.com/awslabs/crossplane-on-eks/issues/127)

Use the [EKS CAS claim file](./eks-cas-claim.yaml) to deploy an EKS cluster wth CAS installed. 

1. Ensure necessary providers are installed. You need `provider-aws`, `provider-kubernetes`, and `provider-helm`:
    ```bash
    kubectl get Providers

    NAME                  INSTALLED   HEALTHY   PACKAGE                                                         AGE
    provider-aws          True        True      xpkg.upbound.io/crossplane-contrib/provider-aws:v0.39.0         88d
    provider-helm         True        True      xpkg.upbound.io/crossplane-contrib/provider-helm:v0.14.0        5d21h
    provider-kubernetes   True        True      xpkg.upbound.io/crossplane-contrib/provider-kubernetes:v0.7.0   5d21h
    ```
    If `provider-helm` is not installed, install it. See [this page](https://marketplace.upbound.io/providers/crossplane-contrib/provider-helm) for available versions and further details. For example: 
    ```bash
    apiVersion: pkg.crossplane.io/v1
    kind: Provider
    metadata:
    name: provider-helm
    spec:
    package: xpkg.upbound.io/crossplane-contrib/provider-helm:v0.14.0' | kubectl apply -f -
    ```

2. Apply necessary compositions. 
    __NOTE:__ All example commands run from the root of this repository. 
    ```bash
    kubectl apply -f compositions/aws-provider/vpc-subnets/
    kubectl apply -f compositions/aws-provider/eks/
    ```

3. Update the [claim file](./eks-cas-claim.yaml) if necessary. If you would like to see resources within the EKS cluster in the AWS console or give admin access to an IAM role, be sure to set the `spec.parameters.adminRole` field.

4. Create a claim and wait for it to finish provisioning this EKS cluster. It usually takes 20-30 min. 
    ```bash
    kubectl apply -f examples/aws-provider/composite-resources/eks/eks-cas-claim.yaml
    ```
    
    You can check for provisioning status with
    ```bash
    kubectl describe -f examples/aws-provider/composite-resources/eks/eks-cas-claim.yaml
    ```

    If you have the tree or lineage plugin, you can also check individual objects' status with
    ```bash
    kubectl tree -A xamazoneks example-cas-jvnsr
    NAMESPACE          NAME                                                              READY  REASON       AGE
                    XAmazonEks/example-cas-jvnsr                                       False  Creating     30m
                    ├─Addon/eks-worker-csi-example-cas                                 False  Unavailable  10m
                    │ └─ProviderConfigUsage/d9449065-fac9-40ae-863d-d5914f895df9      -                   10m
                    ├─Cluster/example-cas                                              True   Available    30m
                    │ ├─ProviderConfigUsage/4b032694-dbbc-402a-aa98-4e2c8a7fc9fb      -                   20m
    crossplane-system  │ └─Secret/02ba3ffa-c50e-4995-ac44-1e9fe882b080-eks-cluster-conn  -                   20m
                    ├─NodeGroup/example-cas-jvnsr-4xtgw                                True   Available    30m
                    │ └─ProviderConfigUsage/5366e98d-4dbf-4d44-8c40-49e05349511c      -                   20m
                    ├─Object/cas-cluster-role-binding-example-cas                      True   Available    30m
                    │ └─ProviderConfigUsage/da087f41-61c3-4622-ac78-e717bea6e2d5      -                   30m
                    ├─Object/cas-cluster-role-example-cas                              True   Available    30m
                    │ └─ProviderConfigUsage/d4746027-6d30-4477-a39c-c12427aa399e      -                   30m

    ```

