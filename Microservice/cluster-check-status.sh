#!/bin/bash

set -euo pipefail

echo "[INFO] Checking Dev EKS Cluster Status and Setting up RBAC..."

CLUSTER_NAME="dev-medium-eks-cluster"
REGION="us-east-1"
ACCOUNT_ID="601672255921"
NAMESPACE="webapps"
SECRET_NAME="mysecretname"

# Step 2: Update Kubeconfig
echo "[INFO] Updating kubeconfig for the cluster..."
/usr/local/bin/aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER_NAME"

# Step 3: Set Kubectl Context
echo "[INFO] Setting kubectl context..."
/usr/local/bin/kubectl config use-context "arn:aws:eks:${REGION}:${ACCOUNT_ID}:cluster/${CLUSTER_NAME}"

# Step 4: Check Current Resources
echo "[INFO] Fetching kube-system resources..."
/usr/local/bin/kubectl -n kube-system get all

# Step 1: Provide RBAC Admin Access
echo "[INFO] Creating IAM Identity Mapping..."
/usr/local/bin/eksctl create iamidentitymapping \
  --cluster "$CLUSTER_NAME" \
  --region "$REGION" \
  --arn "arn:aws:iam::${ACCOUNT_ID}:root" \
  --group system:masters \
  --username admin


# Step 5: Create Namespace
echo "[INFO] Creating namespace: $NAMESPACE..."
/usr/local/bin/kubectl create namespace "$NAMESPACE" || echo "[WARN] Namespace $NAMESPACE already exists"

# Step 6: Apply Service Account YAML
echo "[INFO] Creating Service Account..."
/usr/local/bin/kubectl apply -f svc-acc.yaml

# Step 7: Apply Role YAML
echo "[INFO] Creating Role..."
/usr/local/bin/kubectl apply -f app-role.yaml

# Step 8: Apply RoleBinding YAML
echo "[INFO] Creating RoleBinding..."
/usr/local/bin/kubectl apply -f role-bind.yaml

# Step 9: Create Secret for Service Account
echo "[INFO] Creating Secret for the Service Account..."
/usr/local/bin/kubectl apply -f secret.yaml

# Step 10: Describe the Secret
echo "[INFO] Describing Secret: $SECRET_NAME..."
/usr/local/bin/kubectl describe secret "$SECRET_NAME" -n "$NAMESPACE"
