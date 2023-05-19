# DaskHub composition

## DaskHub with simple password authentication

This example creates a DaskHub installation with simple password authentication. This is suitable for testing environments only. Use a proper [supported authentication methods](https://jupyterhub.readthedocs.io/en/stable/tutorial/getting-started/authenticators-users-basics.html) for your production environments. 

1. Run the following command to create a API token that is used by Dask Gateway and Jupyterhub to talk to each other. This token is also used as user password.

```bash
sed "s/REPLACEME/$(openssl rand -hex 32)/g" examples/aws-provider/composite-resources/daskhub/daskhub-sensitive.yaml | kubectl apply -f -
```

2. Get your EKS cluster's OIDC ID. See [this documentation](https://docs.aws.amazon.com/eks/latest/userguide/associate-service-account-role.html) for more information. Be sure to replace `my-cluster` with your cluster name in the command.

```bash
oidc_provider=$(aws eks describe-cluster --name my-cluster --region $AWS_REGION --query "cluster.identity.oidc.issuer" --output text | sed -e "s/^https:\/\///")
```

3. Update the [claim file](./example-dask-hub-password.yaml) with your OIDC id.

```bash
yq '(.spec.parameters.eksOidc) = "${oidc_provider}"' examples/aws-provider/composite-resources/daskhub/example-dask-hub-password.yaml
```

4. Apply the claim and wait for it to be ready. It typically takes 3-5 minutes.

```bash
kubectl apply -f examples/aws-provider/composite-resources/daskhub/example-dask-hub-password.yaml
```

5. The default public service is disabled. We need to forward connection to access the UI.

```bash
# port forward
kubectl port-forward -n daskhub svc/proxy-public  8080:80
# get your login password
get secret daskhub-sensitive-values --template='{{ index .data "config.yaml" | base64decode}}' | yq '.jupyterhub.hub.services.dask-gateway.apiToken'
```

6. Open your web browser and navigate to [`http://localhost:8080`](http://localhost:8080). You should be able to login with the password obtained above.


