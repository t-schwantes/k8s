#!/bin/bash
set -e

# Source the configuration file to get necessary variables
source "$REMOTE_SCRIPT_DIR/config.sh"

# Registry IP and NodePort from the control node
REGISTRY_IP=$API_SERVER_ADDRESS
NODE_PORT=30000  # NodePort used for the Docker registry

# Define the insecure registry entry for containerd and Docker
CONTAINERD_CONFIG_PATH="/etc/containerd/config.toml"
INSECURE_REGISTRY_ENTRY="\"$REGISTRY_IP:$NODE_PORT\""

# Update containerd config on worker node
echo "Updating containerd config on worker node to include insecure registry $REGISTRY_IP:$NODE_PORT"
if ! grep -q "$REGISTRY_IP:$NODE_PORT" "$CONTAINERD_CONFIG_PATH"; then
    sudo sed -i "/\[plugins.\"io.containerd.grpc.v1.cri\".registry.mirrors\]/a \
    [plugins.\"io.containerd.grpc.v1.cri\".registry.mirrors.\"$REGISTRY_IP:$NODE_PORT\"]\nendpoint = [\"http://$REGISTRY_IP:$NODE_PORT\"]" "$CONTAINERD_CONFIG_PATH"
    echo "Restarting containerd to apply insecure registry changes on worker node..."
    sudo systemctl restart containerd
else
    echo "Insecure registry $REGISTRY_IP:$NODE_PORT is already present in containerd config on worker node."
fi

# Update Docker daemon.json on worker node
echo "Updating Docker daemon.json on worker node to include insecure registry $REGISTRY_IP:$NODE_PORT"
if ! grep -q "$REGISTRY_IP:$NODE_PORT" /etc/docker/daemon.json; then
    if [ -f /etc/docker/daemon.json ]; then
        sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.bak
    fi
    echo "{\"insecure-registries\": [$INSECURE_REGISTRY_ENTRY]}" | sudo tee /etc/docker/daemon.json > /dev/null
    echo "Restarting Docker to apply insecure registry changes on worker node..."
    sudo systemctl restart docker
else
    echo "Insecure registry $REGISTRY_IP:$NODE_PORT is already present in Docker daemon.json on worker node."
fi

echo "Docker registry setup and configuration complete on worker node."
