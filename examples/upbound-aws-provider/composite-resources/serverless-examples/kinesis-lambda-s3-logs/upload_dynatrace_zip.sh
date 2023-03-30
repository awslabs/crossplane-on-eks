#!/bin/bash

set -xueo pipefail

mkdir ${TMPDIR}/dynatrace || true

wget -O ${TMPDIR}dynatrace/dynatrace-aws-log-forwarder.zip https://github.com/dynatrace-oss/dynatrace-aws-log-forwarder/releases/latest/download/dynatrace-aws-log-forwarder.zip

unzip -qo ${TMPDIR}dynatrace/dynatrace-aws-log-forwarder.zip -d ${TMPDIR}dynatrace/

aws s3 cp ${TMPDIR}dynatrace/dynatrace-aws-log-forwarder-lambda.zip s3://${S3_BUCKET}/ --region ${AWS_REGION}
