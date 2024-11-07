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
