# Composition library

Compositions folder contains the Compositions and CompositeResourceDefinition(XRD) files to deploy the Composites for each AWS service.

Compositions and CompositeResourceDefinition(XRD) files split into dedicated folders for each AWS Provider. 

- **AWS Provider**
- **Terrajet AWS Provider**

## Option1 - AWS Provider
The following steps demonstrate the example to deploy the composition to create VPC with AWS Provider

### Deploy Composition and XRD
Deploys VPC Composition file and XRD definition file

```shell
kubectl apply -f compositions/aws-provider/vpc
```

### Deploy Application example
Deploys VPC claim resource which uses the above composition.

```shell
kubectl apply -f examples/aws-provider/composite-resources/vpc/vpc.yaml
```

## Option2: Jet AWS Provider
The following steps demonstrate the example to deploy the VPC with Jet AWS Provider

### Deploy Composition and XRD
Deploys VPC Composition file and XRD definition file
```shell
kubectl apply -f compositions/terrajet-aws-provider/vpc
```

### Deploy Application example
Deploys VPC claim resource which uses the above composition.
```shell
kubectl apply -f examples/terrajet-aws-provider/composition-resources/vpc.yaml
```
