### Prevent provisioning resources that do not have the required tags

This example covers a Gatekeeper policy that denies requests for provisioning
resources without the required tags

Examples and test cases are available under the `samples` directory. 
Tests can be ran using the [gator cli](https://open-policy-agent.github.io/gatekeeper/website/docs/gator/).

To run tests for this example run:
```bash
cd examples/gatekeeper/required-tags/
gator verify . -v
```