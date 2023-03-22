# Test Application for Serverless Examples
This is a test Go application for serverless examples.

## Pre-requisites:
- Go is installed. Find the installation instructions [here](https://go.dev/doc/install).
- AWS CLI is installed and configured. Find the installation instructions [here](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).

## Build, zip, and upload golang function code to s3
Navigate to the function code folder
```
cd composite-resources/serverless/app/
```
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
