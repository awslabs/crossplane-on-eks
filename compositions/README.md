# Composition library

## Deployment Steps - AWS Provider

The following steps demonstrate the example to deploy the VPC with AWS Provider


### Deploy Composition and XRD

```shell
kubectl apply -f compositions/aws-provider/vpc
```


### Deploy Application example

```shell
kubectl apply -f examples/aws-provider/composite-resources/vpc/vpc.yaml
```

## Deployment Steps - Jet AWS Provider

The following steps demonstrate the example to deploy the VPC with Jet AWS Provider

### Deploy Composition and XRD

```shell
kubectl apply -f compositions/terrajet-aws-provider/vpc
```


### Deploy Application example

```shell
kubectl apply -f examples/terrajet-aws-provider/composition-resources/vpc.yaml
```