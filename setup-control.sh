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

run_script "install/docker.sh" "$LOG_DIR/docker.log" 
run_script "install/containerd.sh" "$LOG_DIR/containerd.log"
run_script "install/kubernetes.sh" "$LOG_DIR/kubernetes.log"
run_script "install/cni.sh" "$LOG_DIR/cni.log"
run_script "install/nvidia-container.sh" "$LOG_DIR/nvidia-container.log"

run_script "init-k8s.sh" "$LOG_DIR/init-k8s.log"
run_script "docker-registry.sh" $LOG_DIR/"docker-registry.log"
run_script "jupyterhub-image.sh" $LOG_DIR/"jupyter-image.log"
run_script "worker/setup-worker.sh" $LOG_DIR/"setup-worker.log"
run_script "jhub.sh" "$LOG_DIR/helm.log"
run_script "dashboard-server.sh" "$LOG_DIR/dashboard-server.log"
run_script "tensorboard.sh" "$LOG_DIR/tensorboard.log"
