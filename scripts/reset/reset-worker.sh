#!/bin/bash

# Source config.sh if needed (e.g., for worker node IPs)
source ./config.sh

WORKER_NODE_IP="192.168.0.101"  # IP of the worker node (beast6)
WORKER_NODE_NAME="beast6"       # Name of the worker node in Kubernetes
WORKER_USER="default"           # User for SSH access

# Path to the reset script to be copied to the worker node
RESET_SCRIPT="scripts/reset.sh"
REMOTE_SCRIPT_DIR="/home/default"

# Step 1: Copy the reset script to the worker node
echo "Copying reset.sh to worker node $WORKER_NODE_IP..."
scp "$RESET_SCRIPT" "$WORKER_USER@$WORKER_NODE_IP:$REMOTE_SCRIPT_DIR"

# Step 2: SSH into the worker node, make the reset script executable, and execute it
echo "SSHing into worker node $WORKER_NODE_IP to execute the reset script..."
ssh "$WORKER_USER@$WORKER_NODE_IP" bash -s <<EOF
    echo "Making reset.sh executable and running it on the worker node..."
    sudo chmod +x $REMOTE_SCRIPT_DIR/reset.sh
    sudo $REMOTE_SCRIPT_DIR/reset.sh
EOF

# Step 3: Exit SSH session and drain and delete the node from the Kubernetes cluster
echo "Draining and deleting the worker node $WORKER_NODE_NAME from Kubernetes..."

# Drain the worker node
kubectl drain $WORKER_NODE_NAME --ignore-daemonsets --delete-emptydir-data --force --grace-period=0

# Delete the node from the Kubernetes cluster
kubectl delete node $WORKER_NODE_NAME

echo "Worker node $WORKER_NODE_NAME has been reset and removed from the cluster."
