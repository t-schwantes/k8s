source config.sh


USER_HOME=$(eval echo ~${SUDO_USER})

# Initialize Kubernetes control plane
echo "Initializing Kubernetes control plane..."

# Replace 192.168.0.125 with your actual control plane IP address
sudo kubeadm init --pod-network-cidr=$POD_NETWORK_CIDR \
--apiserver-advertise-address=$API_SERVER_ADDRESS \
--cri-socket=unix:///run/containerd/containerd.sock

# Set up kubeconfig for the original user (not root)
echo "Setting up kubeconfig for kubectl..."
mkdir -p $USER_HOME/.kube
sudo cp -f /etc/kubernetes/admin.conf $USER_HOME/.kube/config
sudo chown $(id -u ${SUDO_USER}):$(id -g ${SUDO_USER}) $USER_HOME/.kube/config

echo "Kubernetes control plane initialized and credentials set."

# Remove NoSchedule taints from the control-plane node
echo "Removing NoSchedule taints from the control-plane node (beast5)..."

kubectl taint nodes beast5 node-role.kubernetes.io/control-plane:NoSchedule-
kubectl taint nodes beast5 node.kubernetes.io/not-ready:NoSchedule-

echo "Taints removed from beast5, node is ready to schedule workloads."


# Apply Flannel network configuration
echo "Applying Flannel network configuration..."

kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

echo "Flannel network configuration applied."

# Create JupyterHub namespace
echo "Creating JupyterHub namespace..."
kubectl create namespace jupyterhub || echo "Namespace jupyterhub already exists."

# Install NFS server on the control plane (if not already installed)
echo "Installing NFS server..."
set +e
sudo apt update
# Re-enable set -e after apt update
set -e
sudo apt install -y nfs-kernel-server

# Create the NFS export directory and set permissions
echo "Creating NFS export directory at $NFS_STORAGE_PATH..."
sudo mkdir -p $NFS_STORAGE_PATH
sudo cp jupyterhub/default-config/bash_profile $NFS_STORAGE_PATH/.bash_profile
sudo cp jupyterhub/default-config/bashrc $NFS_STORAGE_PATH/.bashrc
sudo cp jupyterhub/default-config/condarc $NFS_STORAGE_PATH/.condarc
sudo chmod 777 $NFS_STORAGE_PATH

# Configure the NFS export
echo "Configuring NFS exports..."
if ! grep -q "$NFS_STORAGE_PATH" /etc/exports; then
    echo "$NFS_STORAGE_PATH *(rw,sync,no_subtree_check,no_root_squash)" | sudo tee -a /etc/exports
else
    echo "NFS export already exists in /etc/exports, skipping..."
fi

# Apply the export configuration and restart the NFS service
sudo exportfs -rav
sudo systemctl restart nfs-kernel-server
echo "NFS server configuration completed."

# Verify NFS export
echo "Verifying NFS export..."
sudo exportfs -v

# Apply storage class, PV, and PVC files from the GitHub repository
echo "Applying Kubernetes storage configuration..."

export NFS_SERVER=$API_SERVER_ADDRESS
export NFS_STORAGE_PATH=$NFS_STORAGE_PATH
export STORAGE_SIZE=$STORAGE_SIZE

envsubst < jupyterhub/storage/shared-pv-template.yaml > jupyterhub/storage/shared-pv.yaml
envsubst < jupyterhub/storage/shared-pvc-template.yaml > jupyterhub/storage/shared-pvc.yaml

kubectl apply -f jupyterhub/storage/storageclass.yaml
kubectl apply -f jupyterhub/storage/shared-pv.yaml
kubectl apply -f jupyterhub/storage/shared-pvc.yaml
kubectl apply -f jupyterhub/pod-manager-role/pod-manager-role.yaml
kubectl apply -f jupyterhub/pod-manager-role/pod-manager-rolebinding.yaml

echo "Kubernetes storage configuration applied successfully."
