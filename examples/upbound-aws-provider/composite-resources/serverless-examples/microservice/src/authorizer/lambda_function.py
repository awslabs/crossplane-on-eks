# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

# IMPORTANT: 
#   This is sample implementation of a Lambda Authorizer, it generates IAM policy that allows ALL actions on your API 
#   to be performed by ANYONE who includes correct password value in the Authorization header (it has to match Lambda 
#   function evironment variable AUTHORIZER_PASSWORD).
#   Make sure to update code below to limit access to the resources based on your use case.
#   For more details on how to implement Lambda Authorizer, check out documentation at https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-use-lambda-authorizer.html
#   You may also use the Lambda Authorizer blueprints at https://github.com/awslabs/aws-apigateway-lambda-authorizer-blueprints

import os

AUTHORIZER_PASSWORD = os.getenv('AUTHORIZER_PASSWORD', None)

def lambda_handler(event, context):
    
    authorizationToken=event['authorizationToken']
    if authorizationToken is None:
        raise Exception('Unauthorized') 
    if authorizationToken != AUTHORIZER_PASSWORD:
        raise Exception('Unauthorized')
    
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
