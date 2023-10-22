### Restrict resources provisioning to specific regions

This example covers a Gatekeeper policy that denies requests for resources 
provisioning in any region, except those that are explicitly allowed

Examples and test cases are available under the `samples` directory. 
Tests can be ran using the [gator cli](https://open-policy-agent.github.io/gatekeeper/website/docs/gator/).

To run tests for this example run:
```bash
cd examples/gatekeeper/region-restrict/
gator verify . -v
```