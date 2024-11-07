#!/bin/bash
set -e
chmod +x ./scripts/*.sh

run_script() {
    local script_name=$1
    local log_file=$2

    echo "Running ${script_name}"
    ./scripts/${script_name} > "$log_file" 2>&1

}

LOG_DIR="./logs"
mkdir -p "$LOG_DIR"

run_script "config-system.sh" "$LOG_DIR/config-system.log"

run_script "install/docker.sh" "$LOG_DIR/install/docker.log" 
run_script "install/containerd.sh" "$LOG_DIR/install/containerd.log"
run_script "install/kubernetes.sh" "$LOG_DIR/install/kubernetes.log"
run_script "install/cni.sh" "$LOG_DIR/install/cni.log"
run_script "install/nvidia-container.sh" "$LOG_DIR/install/nvidia-container.log"

run_script "k8s/init.sh" "$LOG_DIR/k8s/init.log"
run_script "k8s/cni.sh" "$LOG_DIR/k8s/cni.log"
run_script "k8s/worker/setup-worker.sh" "$LOG_DIR/k8s/worker/setup-worker.log"

run_script "docker/registry.sh" "$LOG_DIR/docker/registry.log"

run_script "jupyterhub/build-image.sh" "$LOG_DIR/jupyterhub/build-image.log"
run_script "jupyterhub/init.sh" "$LOG_DIR/jupyterhub/init.log"
run_script "jupyterhub/storage.sh" "$LOG_DIR/jupyterhub/storage.log"
run_script "jupyterhub/dashboard-server.sh" "$LOG_DIR/jupyterhub/dashboard-server.log"
run_script "jupyterhub/tensorboard.sh" "$LOG_DIR/jupyterhub/tensorboard.log"

# Add kubernetes api token if you want to add users via the script
# go to jupyterhub, click on token, generate api token
# kubectl create secret generic jupyterhub-api-token --from-literal=token="<api-token>"
# ./scripts/jupyterhub/add-user.sh <username> <password>
