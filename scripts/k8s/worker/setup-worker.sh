#!/bin/bash

# Source the configuration file to get the worker node IPs and user
source config.sh

# Directory on worker nodes to store the scripts
REMOTE_SCRIPT_DIR="/home/default/tmp"

# Generate the kubeadm join command on the control plane (master node)
JOIN_COMMAND=$(kubeadm token create --print-join-command)
echo "Kubeadm join command for workers: $JOIN_COMMAND"

# Function to copy scripts, run setup, and join the cluster on worker nodes
setup_worker_node() {
    local node_ip=$1

    echo "Setting up worker node: $node_ip"

    # Create the scripts directory on the worker node if it doesn't exist
    echo "Creating remote script directory on worker node $node_ip..."
    ssh "$WORKER_USER@$node_ip" "mkdir -p $REMOTE_SCRIPT_DIR"


    # Copy the scripts to the worker node
    echo "Copying scripts to worker node $node_ip..."
    scp -r ./scripts config.sh "$WORKER_USER@$node_ip:$REMOTE_SCRIPT_DIR"

    # SSH into the worker node and run the setup scripts
    ssh "$WORKER_USER@$node_ip" bash -s <<EOF
    	export REMOTE_SCRIPT_DIR="$REMOTE_SCRIPT_DIR"
    
        echo "Making scripts executable on worker node..."
        chmod +x $REMOTE_SCRIPT_DIR/*.sh
        
        echo "Running config-system.sh on worker node..."
        bash $REMOTE_SCRIPT_DIR/scripts/config-system.sh
        
	echo "Running docker.sh on worker node..."
        bash $REMOTE_SCRIPT_DIR/scripts/install/docker.sh
        
        echo "Running containerd.sh on worker node..."
        bash $REMOTE_SCRIPT_DIR/scripts/install/containerd.sh
        
        echo "Running kubernetes.sh on worker node..."
        bash $REMOTE_SCRIPT_DIR/scripts/install/kubernetes.sh
        
	echo "Running nvidia-container.sh on worker node..."
        bash $REMOTE_SCRIPT_DIR/scripts/install/nvidia-container.sh
        
	echo "Running docker-registry-worker.sh on worker node ..."
        bash $REMOTE_SCRIPT_DIR/scripts/k8s/worker/docker-registry-worker.sh        
        
        echo "Joining the worker node to the Kubernetes cluster..."
        sudo $JOIN_COMMAND
        
        echo "Cleaning up: deleting the scripts folder from worker node..."
        rm -rf $REMOTE_SCRIPT_DIR
        
        echo "Worker node $node_ip setup and joined successfully."
EOF

    # Check for errors
    if [ $? -ne 0 ]; then
        echo "Error: Failed to set up worker node $node_ip."
        exit 1
    else
        echo "Worker node $node_ip set up and joined the cluster successfully."
    fi
}

# Loop through all worker nodes and set them up
for node_ip in "${WORKER_NODES[@]}"; do
    setup_worker_node "$node_ip"
done

echo "All worker nodes have been set up and joined the cluster successfully."
