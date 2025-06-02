#!/bin/bash
set -e

# Variables
BUCKET_NAME="microservice-deployment-dev-601672255921"
TABLE_NAME="microservice-terraform-lock-table"
REGION="us-east-1"

echo "Creating S3 bucket: $BUCKET_NAME in $REGION..."

case "$REGION" in
  "us-east-1")
    aws s3api create-bucket \
      --bucket "$BUCKET_NAME" \
      --region "$REGION" || echo "Bucket may already exist."
    ;;
  *)
    aws s3api create-bucket \
      --bucket "$BUCKET_NAME" \
      --region "$REGION" \
      --create-bucket-configuration LocationConstraint="$REGION" || echo "Bucket may already exist."
    ;;
esac

echo "Enabling versioning on bucket..."
aws s3api put-bucket-versioning \
  --bucket "$BUCKET_NAME" \
  --versioning-configuration Status=Enabled \
  --region "$REGION"

echo "Creating DynamoDB table: $TABLE_NAME..."
aws dynamodb create-table \
  --table-name "$TABLE_NAME" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region "$REGION" || echo "Table may already exist."

echo "✅ Backend setup complete."
