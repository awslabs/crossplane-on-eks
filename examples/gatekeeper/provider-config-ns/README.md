### Provider Config name enforcement based on namespace

This example Gatekeeper policy enforces provider config name based on namespaces. For example, if the claim is created in a namespace called `test`, the provider config name used for this managed resource should be `test-provider-config`. See the [template file](./template.yaml) and the [constraint file](./samples/constraint.yaml) for more details.

Examples and test cases are available under the `samples` directory. Tests can be ran using the [gator cli](https://open-policy-agent.github.io/gatekeeper/website/docs/gator/). 

To run tests for this example run: 
```bash
cd examples/gatekeeper/provider-config-ns/
gator verify . -v
```
