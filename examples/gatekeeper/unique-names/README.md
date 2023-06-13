### Block Claim creation that reuses vpcName already managed by another Claim

This example Gatekeeper policy denies requests for claims that use a vpcName already in used by another Claim.

Examples and test cases are available under the `samples` directory. Tests can be ran using the [gator cli](https://open-policy-agent.github.io/gatekeeper/website/docs/gator/).

To run tests for this example run:
```bash
cd examples/gatekeeper/unique-names/
gator verify . -v
```
