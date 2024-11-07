# Check if NVIDIA container toolkit is installed before proceeding
if ! dpkg -l | grep -q nvidia-container-toolkit; then
    echo "NVIDIA container toolkit is not installed. Installing..."

    # Add NVIDIA container toolkit repo to apt sources
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --batch --yes --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
    && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

    # Update apt content
    sudo apt-get update

    # Install NVIDIA container toolkit with a specific version
    NVIDIA_TOOLKIT_VERSION="1.17.0-1"
    echo "Installing NVIDIA container toolkit version ${NVIDIA_TOOLKIT_VERSION}..."
    sudo apt-get install -y nvidia-container-toolkit=${NVIDIA_TOOLKIT_VERSION}
else
    echo "NVIDIA container toolkit is already installed."
fi

# Configure containerd to use NVIDIA as the default runtime
echo "Configuring containerd to use NVIDIA as the default runtime..."
sudo nvidia-ctk runtime configure --runtime=containerd --nvidia-set-as-default

# Restart containerd to apply changes
echo "Restarting containerd service..."
sudo systemctl restart containerd
echo "NVIDIA container toolkit installation complete."
