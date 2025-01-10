# Network
export POD_NETWORK_CIDR="10.244.0.0/16"
export API_SERVER_ADDRESS="172.16.49.54" # Beast5 is control plane node
export JHUB_IP="172.16.49.54" # Domain name "jupyter-dev.wavetronix.com" points to this address

# storage
export SYNOLOGY_IP='172.16.49.55'
export NFS_STORAGE_PATH="/mnt/user-homes/"
export NFS_STORAGE_SIZE="100Gi"
export DOCKER_REGISTRY_PATH="/home/default/docker-registry"
export DOCKER_REGISTRY_SIZE="100Gi"
# Kadalu storage is hard coded 
# The devices need to be unmounted and wiped
# right now kadalu is set to nvme1n1 on beast5 and beast6 replicated twice
# KADALU_BEAST5="/dev/nvme1n1"
# KADALU_BEAST6="/dev/nvme1n1"

# List of worker node IP addresses
export WORKER_NODES=("172.16.49.59") # Beast 6 ip address
export WORKER_USER="default"
