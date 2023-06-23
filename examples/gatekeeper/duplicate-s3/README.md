### Block Claim creation that reuses vpcName already managed by another Claim

This example Gatekeeper policy denies requests for Bucket claims or Bucket MRs, if
there is already a Bucket MR managing the bucket.

Examples and test cases are available under the `samples` directory. Tests can be ran using the [gator cli](https://open-policy-agent.github.io/gatekeeper/website/docs/gator/).

To run tests for this example run:
```bash
cd examples/gatekeeper/duplicate-s3/
gator verify . -v
```
