### Block Claim creation that reuses vpcName already managed by another Claim

This example Gatekeeper policy denies requests for claims with a vpcName already used by another claim, unless they are observe only

Examples and test cases are available under the `samples` directory. Tests can be ran using the [gator cli](https://open-policy-agent.github.io/gatekeeper/website/docs/gator/).

To run tests for this example run:
```bash
cd examples/gatekeeper/unique-names/
gator verify . -v
```
