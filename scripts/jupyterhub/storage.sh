source config.sh

# Install NFS server on the control plane (if not already installed)
echo "Installing NFS server..."
set +e
sudo apt update
# Re-enable set -e after apt update
set -e
sudo apt install -y nfs-kernel-server=1:2.6.1-1ubuntu1.2

# Create the NFS export directory and set permissions
echo "Creating NFS export directory at $NFS_STORAGE_PATH..."
sudo mkdir -p $NFS_STORAGE_PATH
#sudo cp jupyterhub/default-config/bash_profile $NFS_STORAGE_PATH/.bash_profile
#sudo cp jupyterhub/default-config/bashrc $NFS_STORAGE_PATH/.bashrc
#sudo cp jupyterhub/default-config/condarc $NFS_STORAGE_PATH/.condarc
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


echo "Installing csi smb driver"
helm repo add csi-driver-smb https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/master/charts
helm repo update
helm install csi-driver-smb csi-driver-smb/csi-driver-smb --namespace kube-system --version v1.16.0
echo "csi smb driver installation complete"


echo "Kubernetes storage configuration applied successfully."
