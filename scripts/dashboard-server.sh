#!/bin/bash

# Source the configuration file to get necessary variables
source config.sh

# Variables
DOCKER_IMAGE_NAME="jupyterhub-dashboard"
DOCKER_REGISTRY="${API_SERVER_ADDRESS}:30000"
WORKING_DIR="jupyterhub/server"
K8S_DEPLOYMENT="${WORKING_DIR}/deployment.yaml"
K8S_SERVICE="${WORKING_DIR}/service.yaml"

# Step 1: Build the Docker image with --network=host
echo "Building Docker image..."
cd ${WORKING_DIR}
docker build --network=host -t ${DOCKER_IMAGE_NAME}:latest .

# Step 2: Tag the Docker image for the registry
echo "Tagging Docker image..."
docker tag ${DOCKER_IMAGE_NAME}:latest ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:latest

# Step 3: Push the Docker image to the repository
echo "Pushing Docker image to registry..."
docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:latest

cd -

# Step 4: Apply the Kubernetes deployment, service, and port-forward YAMLs
echo "Applying Kubernetes deployment..."
kubectl apply -f ${K8S_DEPLOYMENT}

echo "Applying Kubernetes service..."
kubectl apply -f ${K8S_SERVICE}

echo "Dashboard setup complete!"
