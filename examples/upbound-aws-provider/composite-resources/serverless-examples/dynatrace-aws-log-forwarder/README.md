



Create an AWS bucket and upload the dynatrace lambda code, you can download latest version from github repository [github.com/dynatrace-oss](https://github.com/dynatrace-oss/dynatrace-aws-log-forwarder/releases)

Use the helper script `upload_dynatrace_zip.sh` to download latest zip file lambda, and upload to s3 using the CLI, inspect the script in case you need to customize the aws cli command
```sh
S3_BUCKET="lambda-uploads-carrlos" ./upload_dynatrace_zip.sh
```

Create a dynatrace account (there is a 16 free trial) and create an API Key for log ingestion,
for more information on creating the key and enabling log monitoring see the doc [Amazon CloudWatch Logs monitoring
](https://www.dynatrace.com/support/help/setup-and-configuration/setup-on-cloud-platforms/amazon-web-services/amazon-web-services-integrations/aws-service-metrics/cloudwatch-logs)

If you want to use the API to generate the token you can use the followig command
```sh
curl -X POST "https://XXXXXXXX.live.dynatrace.com/api/v2/apiTokens" -H "accept: application/json; charset=utf-8" -H "Content-Type: application/json; charset=utf-8" -d "{\"name\":\"lambda-ingest-logs\",\"scopes\":[\"logs.ingest\"]}" -H "Authorization: Api-Token XXXXXXXX"
```


Use the file template `environmentconfig-tmpl.yaml` to create a file `environmentconfig.yaml`

Set the variables `DYNATRACE_ENV_URL` and `DYNATRACE_API_KEY` in the following command with your valid values.

```sh
export DYNATRACE_ENV_URL="https://XXXXXXXX.live.dynatrace.com"
export DYNATRACE_API_KEY="dt0c01.XXXXXXXX"
export S3_BUCKET="lambda-uploads-carrlos"
envsubst < "environmentconfig-tmpl.yaml" > "environmentconfig.yaml"
```
Create Crossplane environment config to be us with the Composition.

```sh
kubectl apply -f environmentconfig.yaml
```

Currently there is an [issue](https://github.com/upbound/upjet/issues/95) with Upbound crossplane provider in SubcriptionFilters using matchSelectors only work with Kinesis Stream, not other destinations.

Get the name of the Kinesis Data Firehose created previously using the following command:

Using the the following labes on the created claim `test-logs-firehose-s3-lambda`
```sh
KINESIS_CLAIM_NAME="test-logs-firehose-s3-lambda"
DESTINATION_KINESIS_ARN=$(kubectl get firehoseapps.awsblueprints.io ${KINESIS_CLAIM_NAME} \
  -o 'jsonpath={.status.kinesisArn}')
echo "Found Kinesis Data Firehose => ${DESTINATION_KINESIS_ARN}"
```

Use the file template `claim-subscription-tmpl.yaml` to create a file `claim-subscription.yaml`

- Edit file to customize the `filterPattern` and change value `default` if you installed in a different namespace.
- Substitute the variable `${DESTINATION_KINESIS_ARN}` with the value we got previously
- Substitute the variable `${CLOUDWATCH_LOG_GROUP}` with the desired CloudWatch log group to forward logs, for example the Amazon EKS Control Plane logs that contain Kubernetes Audit Logs, you can use the value `/aws/eks/crossplane-blueprints/cluster` which is the EKS cluster created in this git repo installed with Crossplane.

You can use the following command:
```sh
export NAMESPACE="default"
export KINESIS_CLAIM_NAME="test-logs-firehose-s3-lambda"
export CLOUDWATCH_LOG_GROUP="/aws/eks/crossplane-blueprints/cluster"
export DESTINATION_KINESIS_ARN="${DESTINATION_KINESIS_ARN}"
envsubst < "claim-subscription-tmpl.yaml" > "claim-subscription.yaml"
```

Create the claim for the CloudWatch log group subscription filter, you can create up to two subscription filters per log group.

```sh
kubectl apply -f claim-subscription.yaml
```
