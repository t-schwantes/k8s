#!/bin/bash

# Source configuration file for environment variables
source config.sh

# Variables
DOCKER_IMAGE_NAME="tensorboard"
DOCKER_REGISTRY="${API_SERVER_ADDRESS}:30000"
DOCKER_IMAGE_TAG="latest"
IMAGE_PATH="jupyterhub/tensorboard"
YAML_FILE="tensorboard-service.yaml"
DEPLOYMENT_YAML_FILE="tensorboard-deployment.yaml"

# Change to the tensorboard image directory
cd ${IMAGE_PATH}

# Build the Docker image without cache
echo "Building Docker image ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}..."
docker build --network=host --no-cache -t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} .

# Tag the image for the registry
echo "Tagging image as ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}..."
docker tag ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}

# Push the image to the Docker registry
echo "Pushing image to registry ${DOCKER_REGISTRY}..."
docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}

# Change back to the original directory
cd -

# Apply the TensorBoard service configuration to Kubernetes
echo "Applying TensorBoard service configuration to Kubernetes..."
kubectl apply -f ${IMAGE_PATH}/${YAML_FILE}

echo "Applying TensorBoard ServiceAccount, Role, and RoleBinding to Kubernetes..."
kubectl apply -f ${IMAGE_PATH}/service-account/tensorboard-sa.yaml
kubectl apply -f ${IMAGE_PATH}/service-account/tensorboard-role.yaml
kubectl apply -f ${IMAGE_PATH}/service-account/tensorboard-rolebinding.yaml


# Apply the TensorBoard deployment configuration to Kubernetes
echo "Applying TensorBoard deployment configuration to Kubernetes..."
envsubst < jupyterhub/tensorboard/tensorboard-deployment-template.yaml > jupyterhub/tensorboard/tensorboard-deployment.yaml
kubectl apply -f ${IMAGE_PATH}/${DEPLOYMENT_YAML_FILE}

echo "TensorBoard image, service, and deployment setup completed successfully."

