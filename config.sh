# Network
export POD_NETWORK_CIDR="10.244.0.0/16"
export API_SERVER_ADDRESS="172.16.49.54"
export JHUB_IP="172.16.49.127"

# storage
#export SYNOLOGY_IP='172.16.49.60'
export SYNOLOGY_IP='172.16.49.55'
export NFS_STORAGE_PATH="/home/default/tmp_pv"
export NFS_STORAGE_SIZE="100Gi"
export DOCKER_REGISTRY_PATH="/home/default/docker-registry"
export DOCKER_REGISTRY_SIZE="10Gi"

# List of worker node IP addresses
export WORKER_NODES=("172.16.49.59")
export WORKER_USER="default"
