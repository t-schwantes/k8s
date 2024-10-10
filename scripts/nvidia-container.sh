# Install NVIDIA container toolkit and configure containerd to support GPUs
echo "Adding NVIDIA container toolkit repository to apt sources..."

# Add NVIDIA container toolkit repo to apt sources
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --batch --yes --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
&& curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

# Update apt content
set +e
sudo apt update
# Re-enable set -e after apt update
set -e

# Install NVIDIA container toolkit
echo "Installing NVIDIA container toolkit..."
sudo apt install -y nvidia-container-toolkit

# Configure containerd to use NVIDIA as the default runtime
echo "Configuring containerd to use NVIDIA as the default runtime..."
sudo nvidia-ctk runtime configure --runtime=containerd --nvidia-set-as-default

# Restart containerd to apply changes
echo "Restarting containerd service..."
sudo systemctl restart containerd

echo "NVIDIA container toolkit installation complete."


