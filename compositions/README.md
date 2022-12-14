# Composition library

Compositions folder contains the Compositions and CompositeResourceDefinition(XRD) files to deploy the Composites for each AWS service.

Compositions and CompositeResourceDefinition(XRD) files split into dedicated folders for each AWS Provider.

## AWS Provider
The following steps demonstrate the example to deploy the composition to create VPC with AWS Provider

### Deploy Composition and XRD
Deploys VPC Composition file and XRD definition file

```shell
kubectl apply -f compositions/aws-provider/vpc
```

You can also deploy all Compositions and XRD by running
```shell
kubectl -k compositions
```

### Deploy Application example
Deploys VPC claim resource which uses the above composition.

```shell
kubectl apply -f examples/aws-provider/composite-resources/vpc/vpc.yaml
```

# Configuration Packages

Each folder contains a Crossplane configuration [package](https://crossplane.io/docs/v1.9/concepts/packages.html) definition which bundles all compositions into a single OCI image. 

This is how you build and push the crossplane-aws-blueprints configuration package:
```shell
cd aws-provider
export REPO=example-docker/crossplane-aws-blueprints
kubectl crossplane build configuration
kubectl crossplane push configuration $REPO:v0.0.1
```

And this is how you would install that package on to your control plane:
```shell
kubectl crossplane install configuration $REPO:v0.0.1
```
or apply a configuration declaration:
```yaml
apiVersion: pkg.crossplane.io/v1
kind: Configuration
metadata:
  name: crossplane-aws-blueprints
spec:
  package: example-docker/crossplane-aws-blueprints:v0.0.1
```