# Composition library

## Deployment Steps - AWS Provider

The following steps demonstrate the example to deploy the VPC with AWS Provider


### Deploy Composition and XRD

```shell
cd compositions/aws-provider/vpc

kubectl apply -f .
```


### Deploy Application example

```shell
cd examples/aws-provider/composite-resources/vpc

kubectl apply -f vpc.yaml
```

## Deployment Steps - Jet AWS Provider

The following steps demonstrate the example to deploy the VPC with Jet AWS Provider

### Deploy Composition and XRD

```shell
cd compositions/terrajet-aws-provider/vpc

kubectl apply -f .
```


### Deploy Application example

```shell
cd examples/terrajet-aws-provider/composition-resources

kubectl apply -f vpc.yaml
```