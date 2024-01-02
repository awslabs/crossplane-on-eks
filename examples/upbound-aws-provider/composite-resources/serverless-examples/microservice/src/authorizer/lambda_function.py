# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

# IMPORTANT: 
#     This is sample implementation of a Lambda Authorizer, it generates IAM policy that allows ALL actions on your API to be performed by ANYONE
#     Make sure to update code below to limit access to the resources based on your use case
#     For more details on how to implement Lambda Authorizer, check out documentation at https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-use-lambda-authorizer.html
#     You may also use the Lambda Authorizer blueprints at https://github.com/awslabs/aws-apigateway-lambda-authorizer-blueprints

def lambda_handler(event, context):

    authResponse = {
        "principalId": "TestUser",
        "policyDocument": {
        "Version": "2012-10-17",
        "Statement": [
        {
            "Action": "execute-api:Invoke",
            "Effect": "Allow",
            "Resource": [
                "arn:aws:execute-api:*:*:*/*/*/*"
            ]
        }]}}
    return authResponse
