echo "Setting up containerd runtime..."

# Download and store Docker GPG key without asking for confirmation
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker.gpg --batch --yes

# Add the Docker repository without prompting for confirmation
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package lists and install containerd
set +e
sudo apt update
# Re-enable set -e after apt update
set -e

echo "Installing containerd..."
sudo apt install -y containerd.io=1.7.22-1 --allow-downgrades

# Stop containerd service to modify configuration
echo "Stopping containerd service..."
sudo systemctl stop containerd

# Backup the original containerd config file
echo "Backing up containerd config file..."
sudo mv /etc/containerd/config.toml /etc/containerd/config.toml.orig

# Generate new default containerd configuration
echo "Generating new containerd configuration..."
sudo containerd config default | sudo tee /etc/containerd/config.toml

# Modify containerd configuration to use systemd for cgroups
echo "Configuring containerd to use systemd as the cgroup driver..."

# Use sed to find 'SystemdCgroup = false' and change it to 'SystemdCgroup = true'
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

# Restart containerd service
echo "Starting containerd service..."
sudo systemctl start containerd
