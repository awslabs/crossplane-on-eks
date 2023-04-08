# Test Application for Serverless Examples
This is a test Go application for serverless examples.

## Pre-requisites:
- Go is installed. Find the installation instructions [here](https://go.dev/doc/install).
- AWS CLI is installed and configured. Find the installation instructions [here](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).
- Docker is installed. Find the installation instructions [here](https://docs.docker.com/engine/install/).

Navigate to the function code folder
```shell
cd ../object-processor-app/
```
## Option 1: Container
This option contains commands to build the Go binary, build a Docker image, and create ECR repo and upload the image to it.
First, set the region, ECR_URL, and IMAGE_NAME as environment variables.
```shell
export AWS_REGION=<replace-me-with-aws-region> # this should make aws cli pointing to the region without explicitly passing --region 
export ECR_URL=$(aws sts get-caller-identity|jq -r ".Account" | tr -d '[:space:]').dkr.ecr.$AWS_REGION.amazonaws.com
export IMAGE_NAME=<replace-me-with-image-name>
```
Log in to ECR
```shell
aws ecr get-login-password | docker login --username AWS --password-stdin $ECR_URL
```
Create ECR repository
```shell
aws ecr create-repository --repository-name $IMAGE_NAME
```
Build the Go binary
```shell
GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o main main.go
```
Set the `DOCKER_IMAGE` env var, this step is nessasary to properly escape the ':' for the subsequent docker commands
```shell
export DOCKER_IMAGE=$ECR_URL/$IMAGE_NAME\:latest
```
Build the docker image
```shell
docker build -t $DOCKER_IMAGE . 
```
Upload the docker image to ECR
```shell
docker push $DOCKER_IMAGE
```

## Option 2: Zip file to S3
Executing the `build-and-upload-zip.sh` script creates an S3 bucket in a specified region, builds and zips the Go function, and uploads the ZIP file to the S3 bucket. If the bucket already exists and you have access to it, the script will print a message and continue with the upload. If the options are not specified, the script will use the values of the S3_BUCKET and REGION environment variables.
```
export S3_BUCKET=<unique-s3-bucket-name>
export REGION=<region>
./build-and-upload-zip.sh
```
Or you can just pass bucket name and region as options
```
./build-and-upload-zip.sh --bucket <unique-s3-bucket-name> --region <region>
```
