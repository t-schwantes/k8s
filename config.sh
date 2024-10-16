# Network
export POD_NETWORK_CIDR="10.244.0.0/16"
export API_SERVER_ADDRESS="192.168.0.125"
export JHUB_IP="192.168.0.127"

# storage
export NFS_STORAGE_PATH="/home/default/tmp_pv"
export NFS_STORAGE_SIZE="100Gi"
export DOCKER_REGISTRY_PATH="/home/default/docker-registry"
export DOCKER_REGISTRY_SIZE="10Gi"

# List of worker node IP addresses
export WORKER_NODES=("192.168.0.101")
export WORKER_USER="default"
