#!/bin/bash
# Source the configuration file to get necessary variables
source config.sh

# Check if the DOCKER_REGISTRY_PATH exists, create it if not, and set permissions
if [ ! -d "$DOCKER_REGISTRY_PATH" ]; then
    echo "Creating Docker registry path at $DOCKER_REGISTRY_PATH"
    mkdir -p "$DOCKER_REGISTRY_PATH"
    chmod 777 "$DOCKER_REGISTRY_PATH"
    echo "Docker registry path created and permissions set to 777."
else
    echo "Docker registry path $DOCKER_REGISTRY_PATH already exists."
fi

# Apply the registry Persistent Volume and Deployment
echo "Setting up Docker registry with PVC and Deployment..."
envsubst < docker/registry-pvc-template.yaml > docker/registry-pvc.yaml
kubectl apply -f docker/registry-pvc.yaml
kubectl apply -f docker/registry.yaml

# Wait for the registry pod to be in 'Running' state
echo "Waiting for the Docker registry pod to be ready..."
while [[ $(kubectl get pods -l app=docker-registry -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do
    echo "Waiting for Docker registry to be ready..."
    sleep 5
done

# Registry IP and NodePort to add to containerd and Docker
REGISTRY_IP=$API_SERVER_ADDRESS
NODE_PORT=30000  # NodePort used for the Docker registry

# Define insecure registry entry for containerd
CONTAINERD_CONFIG_PATH="/etc/containerd/config.toml"
INSECURE_REGISTRY_ENTRY="\"$REGISTRY_IP:$NODE_PORT\""

# Update containerd config
echo "Updating containerd config to include insecure registry $REGISTRY_IP:$NODE_PORT"
if ! grep -q "$REGISTRY_IP:$NODE_PORT" "$CONTAINERD_CONFIG_PATH"; then
    sudo sed -i "/\[plugins.\"io.containerd.grpc.v1.cri\".registry.mirrors\]/a \
    [plugins.\"io.containerd.grpc.v1.cri\".registry.mirrors.\"$REGISTRY_IP:$NODE_PORT\"]\nendpoint = [\"http://$REGISTRY_IP:$NODE_PORT\"]" "$CONTAINERD_CONFIG_PATH"
    echo "Restarting containerd to apply insecure registry changes..."
    sudo systemctl restart containerd
else
    echo "Insecure registry $REGISTRY_IP:$NODE_PORT is already present in containerd config."
fi

# Update Docker daemon.json
echo "Updating Docker daemon.json to include insecure registry $REGISTRY_IP:$NODE_PORT"
if ! grep -q "$REGISTRY_IP:$NODE_PORT" /etc/docker/daemon.json; then
    if [ -f /etc/docker/daemon.json ]; then
        sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.bak
    fi
    echo "{\"insecure-registries\": [$INSECURE_REGISTRY_ENTRY]}" | sudo tee /etc/docker/daemon.json > /dev/null
    echo "Restarting Docker to apply insecure registry changes..."
    sudo systemctl restart docker
else
    echo "Insecure registry $REGISTRY_IP:$NODE_PORT is already present in Docker daemon.json."
fi

echo "Docker registry setup and configuration complete."
