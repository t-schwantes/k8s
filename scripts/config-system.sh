# Update package lists
echo "Updating package lists..."
set +e
sudo apt update
set -e

# Upgrade installed packages to the latest versions
echo "Performing a distribution upgrade..."
sudo apt dist-upgrade -y
echo "Installing net-tools..."
sudo apt install -y net-tools

# Turn swap off
echo "Turning off swap..."
sudo swapoff -a

# Modify /etc/fstab to keep swap off
echo "Disabling swap in /etc/fstab if not already disabled..."
sudo sed -i '/^\/swap.img[[:space:]]/ s/^/#/' /etc/fstab
echo "Swap has been disabled and removed from fstab."

# Load required kernel modules
echo "Loading overlay and br_netfilter kernel modules..."
sudo modprobe overlay
sudo modprobe br_netfilter

# Ensure kernel modules are loaded on boot
echo "Ensuring overlay and br_netfilter are loaded on boot..."
sudo cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
echo "Kernel modules loaded and configured to load on boot."

# Set up iptables for Kubernetes networking
echo "Setting up iptables for Kubernetes networking..."
sudo cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply the new sysctl settings
echo "Applying sysctl settings..."
sudo sysctl --system
