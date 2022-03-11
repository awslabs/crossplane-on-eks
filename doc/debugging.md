# Debugging CompositeResourceDefinitions (XRD) and Compositions

## General debugging step

Most error messages are logged to resources' event field. Whenever your Composite Resources are not getting provisioned, follow the following:
1. Get the events for the root resource using `kubectl describe` or `kubectl get event`
2. If there are errors in the events, address them. 
3. If no errors, follow its sub-resources. `kubectl get <KIND> <NAME> -o=jsonpath='{.spec.resourceRef}{" "}{.spec.resourceRefs}' | jq`
4. Go back to step 1 using one of resources returned by step 3. 

_Note:_ Debugging is also enabled for the AWS provider pods. You may find it
useful to check the logs for the provider pods for extra information on
failures. You can also disable logging
[here](/bootstrap/eksctl/crossplane/aws-provider.yaml#L24).

```bash
# kubectl get pods -n crossplane-system
NAME                                                READY   STATUS    RESTARTS   AGE
crossplane-5b6896bb4c-mjr8x                         1/1     Running   0          12d
crossplane-rbac-manager-7874897d59-fc9wf            1/1     Running   0          12d
provider-aws-f6a4a9bdba04-84ddf67474-z78nl          1/1     Running   0          12d
provider-kubernetes-cfae2275d58e-6b7bcf5bb5-2rjk2   1/1     Running   0          8d

# For the AWS provider logs
# kubectl -n crossplane-system logs provider-aws-f6a4a9bdba04-84ddf67474-z78nl | less

# For Crossplane core logs
# kubectl -n crossplane-system logs crossplane-5b6896bb4c-mjr8x  | less
```

## Debugging Example

### Composition
An example application was deployed as a claim of a composite resource. Kind = `ExampleApp`. Name = `example-application`. 

The example application never reaches available state. 


1. Run `kubectl describe exampleapp example-application`
    ```
    Status:
    Conditions:
        Last Transition Time:  2022-03-01T22:57:38Z
        Reason:                Composite resource claim is waiting for composite resource to become Ready
        Status:                False
        Type:                  Ready
    Events:                    <none>
    ```
2. No error in events. Find its cluster scoped resource. 
    ```bash
    # kubectl get exampleapp example-application -o=jsonpath='{.spec.resourceRef}{" "}{.spec.resourceRefs}' | jq

    {
      "apiVersion": "awsblueprints.io/v1alpha1",
      "kind": "XExampleApp",
      "name": "example-application-xqlsz"
    }
    ```
3. In the above output, we see the cluster scoped resource for this claim. Kind = `XExampleApp` name = `example-application-xqlsz`
4. Get the cluster resource's event. 
    ```bash
    # kubectl describe xexampleapp example-application-xqlsz

    Events:
    Type     Reason                   Age               From                                                             Message
    ----     ------                   ----              ----                                                             -------
    Normal   PublishConnectionSecret  9s (x2 over 10s)  defined/compositeresourcedefinition.apiextensions.crossplane.io  Successfully published connection details
    Normal   SelectComposition        6s (x6 over 11s)  defined/compositeresourcedefinition.apiextensions.crossplane.io  Successfully selected composition
    Warning  ComposeResources         6s (x6 over 10s)  defined/compositeresourcedefinition.apiextensions.crossplane.io  cannot render composed resource from resource template at index 3: cannot use dry-run create to name composed resource: an empty namespace may not be set during creation
    Normal   ComposeResources         6s (x6 over 10s)  defined/compositeresourcedefinition.apiextensions.crossplane.io  Successfully composed resources
    ```
5. We see errors in the events. It is complaining about not specifying namespace in its compositions. For this particular kind of error, we can get its sub-resources and check which one is not created.

    ```bash
    # kubectl get xexampleapp example-application-xqlsz -o=jsonpath='{.spec.resourceRef}{" "}{.spec.resourceRefs}' | jq
    [
        {
            "apiVersion": "awsblueprints.io/v1alpha1",
            "kind": "XDynamoDBTable",
            "name": "example-application-xqlsz-6j9nm"
        },
        {
            "apiVersion": "awsblueprints.io/v1alpha1",
            "kind": "IAMPolicy",
            "name": "example-application-xqlsz-lp9wt"
        },
        {
            "apiVersion": "awsblueprints.io/v1alpha1",
            "kind": "IAMPolicy",
            "name": "example-application-xqlsz-btwkn"
        },
        {
            "apiVersion": "awsblueprints.io/v1alpha1",
            "kind": "IRSA"
        }
    ]
    ```
6. Notice the last element in the array does not have a name. When a resource in composition fails validation, the resource object is not created and will not have a name. For this particular issue, we need to specify the namespace for the IRSA resource. 

### Composition Definition

Debugging Composition Definitions is similar to debugging Compositions. 

1. Get XRD 
    ```bash
    # kubectl get xrd testing.awsblueprints.io
    NAME                       ESTABLISHED   OFFERED   AGE
    testing.awsblueprints.io                           66s
    ```
2. Notice its status it not established. We describe this XRD to get its events
    ```bash
    # kubectl describe xrd testing.awsblueprints.io
    Events:
    Type     Reason              Age                    From                                                             Message
    ----     ------              ----                   ----                                                             -------
    Normal   ApplyClusterRoles   3m19s (x3 over 3m19s)  rbac/compositeresourcedefinition.apiextensions.crossplane.io     Applied RBAC ClusterRoles
    Normal   RenderCRD           18s (x9 over 3m19s)    defined/compositeresourcedefinition.apiextensions.crossplane.io  Rendered composite resource CustomResourceDefinition
    Warning  EstablishComposite  18s (x9 over 3m19s)    defined/compositeresourcedefinition.apiextensions.crossplane.io  cannot apply rendered composite resource CustomResourceDefinition: cannot create object: CustomResourceDefinition.apiextensions.k8s.io "testing.awsblueprints.io" is invalid: metadata.name: Invalid value: "testing.awsblueprints.io": must be spec.names.plural+"."+spec.group
    ```
3. We see in the events that CRD cannot be generated for this XRD. In this case, we need to ensure the name is `spec.names.plural+"."+spec.group`
