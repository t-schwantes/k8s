#!/bin/bash

# Source configuration file for environment variables
source config.sh

# Variables
DOCKER_IMAGE_NAME="base"
DOCKER_REGISTRY="${API_SERVER_ADDRESS}:30000"
DOCKER_IMAGE_TAG="latest"
IMAGE_PATH="jupyterhub/image"

# Change to the image directory
cd ${IMAGE_PATH}

# Build the Docker image
echo "Building Docker image ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}..."
docker build --no-cache --network=host -t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} .

# Tag the image for the registry
echo "Tagging image as ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}..."
docker tag ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}

# Push the image to the Docker registry
echo "Pushing image to registry ${DOCKER_REGISTRY}..."
docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}

echo "Docker image ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} has been successfully pushed to ${DOCKER_REGISTRY}"

# Change back to the original directory
cd -
