source config.sh

echo "JHUB_IP is set to: $JHUB_IP"

echo "Installing Helm..."

# Create JupyterHub namespace
echo "Creating JupyterHub namespace..."
kubectl create namespace jupyterhub || echo "Namespace jupyterhub already exists."

# Download the Helm installation script
sudo curl -fsSL -o /usr/local/bin/get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3

# Make the Helm installation script executable
sudo chmod 700 /usr/local/bin/get_helm.sh

# Run the Helm installation script
sudo /usr/local/bin/get_helm.sh

echo "Helm installation complete."

# Add Helm repositories for JupyterHub and NVIDIA device plugin
echo "Adding Helm repositories for JupyterHub and NVIDIA device plugin..."

# Check if the JupyterHub repository is already added, if not, add it
if ! helm repo list | grep -q 'jupyterhub'; then
    helm repo add jupyterhub https://jupyterhub.github.io/helm-chart/
else
    echo "JupyterHub Helm repository already exists, skipping..."
fi

# Check if the NVIDIA device plugin repository is already added, if not, add it
if ! helm repo list | grep -q 'nvdp'; then
    helm repo add nvdp https://nvidia.github.io/k8s-device-plugin
else
    echo "NVIDIA device plugin Helm repository already exists, skipping..."
fi

# Update Helm repositories to pull the latest charts
helm repo update

echo "Helm repositories added and updated."


# Install JupyterHub using the provided configuration file
echo "Installing JupyterHub with Helm using config.yaml..."
helm upgrade --install jupyterhub jupyterhub/jupyterhub \
  --namespace jupyterhub \
  --values jupyterhub/config.yaml \
  --version 4.0.0


# Patch the JupyterHub proxy to use a LoadBalancer with an external IP
# Replace the IP address below with the desired external IP address
echo "Patching the JupyterHub proxy service to use a LoadBalancer..."
kubectl patch svc proxy-public -n jupyterhub \
  -p "{\"spec\": {\"type\": \"LoadBalancer\", \"externalIPs\":[\"$JHUB_IP\"]}}"


# Add the NVIDIA Helm repository and update it
echo "Adding NVIDIA Helm repository for GPU Operator..."
helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
   && helm repo update

# Install the GPU Operator, disabling driver and toolkit installation since we've already installed them
echo "Installing NVIDIA GPU Operator with custom configuration..."
helm install --wait gpu-operator \
  -n gpu-operator --create-namespace \
  nvidia/gpu-operator \
  --set driver.enabled=false \
  --set toolkit.enabled=false \
  --version v24.9.0


echo "NVIDIA GPU Operator installation complete."

echo "JupyterHub setup complete."


