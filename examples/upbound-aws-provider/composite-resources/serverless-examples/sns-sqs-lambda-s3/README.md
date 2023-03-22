# Example to deploy serverless architecture
This example deploys the architecture depicted on the diagram. First, it applies the Crossplane XRD and Compositions. Then it applies the Claim that creates all the AWS resources, and deploys the code to the Lambda funtion. Last, it send a message to SNS Topic and track it get passed to the SQS Queue, that triggers the Lambda fuction, which posts the results in the S3 bucket.
   
![Serverless diagram](../../../diagrams/serverless.png)

## Pre-requisites:
 - [Upbound AWS Provider Crossplane Blueprint Examples](../../../README.md)
 - [serverless app](../object-processor-app/README.md)

### Deploy XRDs and Compositions

```shell
kubectl apply -k .
```

Verify the XRDs
```
kubectl get xrds
```
Expected output
```
NAME                                   ESTABLISHED   OFFERED   AGE
eventsourcemappings.awsblueprints.io   True                    5m
iampolicies.awsblueprints.io           True                    5m
xencryptionkeys.awsblueprints.io       True          True      5m
xfanouts.awsblueprints.io              True          True      5m
xlambdafunctions.awsblueprints.io      True          True      5m
xnotifications.awsblueprints.io        True          True      5m
xobjectstorages.awsblueprints.io       True          True      5m
xqueues.awsblueprints.io               True          True      5m
xserverlessapp.awsblueprints.io        True          True      5m
```

Verify the Compositions
```
kubectl get compositions
```
Expected output
```
NAME                                            AGE
container.lambda.aws.upbound.awsblueprints.io   5m
read-kms.iampolicy.awsblueprints.io             5m
read-s3.iampolicy.awsblueprints.io              5m
read-sqs.iampolicy.awsblueprints.io             5m
s3.lambda.aws.upbound.awsblueprints.io          5m
s3bucket.awsblueprints.io                       5m
sns.notification.upbound.awsblueprints.io       5m
sqs.esm.awsblueprints.io                        5m
sqs.queue.aws.upbound.awsblueprints.io          5m
write-s3.iampolicy.awsblueprints.io             5m
write-sqs.iampolicy.awsblueprints.io            5m
xencryptionkeys-kms.awsblueprints.io            5m
xfanout.awsblueprints.io                        5m
xobject-processor.awsblueprints.io              5m
```

#### Update and apply the claim
```
cd claim
```
Replace the bucket name and region in the claim with the ones set in the pre-requizite step [serverless app](../object-processor-app/README.md) where the `function.zip` file is uploaded.
```
sed -i -e "s/replace-with-unique-s3-bucket/$S3_BUCKET/" sns-sqs-lambda-s3-claim.yaml
sed -i -e "s/replace-with-aws-region/$REGION/" sns-sqs-lambda-s3-claim.yaml
```
Apply the claim
```
kubectl apply -f sns-sqs-lambda-s3-claim.yaml
```
Validate the claim
```
kubectl get serverlessapp
```
Expected result (it might take sometime before READY=True)
```
NAME              SYNCED   READY   CONNECTION-SECRET   AGE
test-serverless   True     True                        20m
```

#### Test
Use the following command to get the SNS topic ARN and store it in $SNS_TOPIC_ARN environment variable
```
SNS_TOPIC_ARN=$(aws sns list-topics |jq -r '.Topics | map(select(.TopicArn | contains("function-sns-sqs-test-serverless"))) | .[0].TopicArn' | tr -d '[:space:]')
```
The command will only store the first topic that contains `function-sns-sqs-test-serverless` in the name. Validate you have the correct topic:
```
echo $SNS_TOPIC_ARN
```
Publish a message to the topic.
```
aws sns publish --topic-arn $SNS_TOPIC_ARN --message abc
```
Or push 100 messages to the topic.
```
for i in {1..100} ; do aws sns publish --topic-arn $SNS_TOPIC_ARN --message abc ; done
```

Navigate to the AWS console and observe the message getting passed to the SQS, triggering the Lambda, and publishing the result in the S3 bucket.

## Clean Up
Delete the serverless application
```
kubectl delete -f sns-sqs-lambda-s3-claim.yaml
```
Delete the bucket
```
aws s3 rm s3://${S3_BUCKET}/function.zip
aws s3api delete-bucket --bucket ${S3_BUCKET} # This will fail when the bucket is not empty.
```
Delete the XRDs and Compositions
```
cd ..
kubectl delete -k .
```
