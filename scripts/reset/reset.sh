#!/bin/bash

# Reset kubeadm (force to bypass the confirmation prompt)
echo "Resetting Kubernetes cluster..."
sudo kubeadm reset --force

# Remove CNI configurations
echo "Removing CNI configurations..."
sudo rm -rf /etc/cni/net.d
sudo rm -rf /var/lib/cni

# Remove Kubernetes directories
echo "Removing Kubernetes directories..."
sudo rm -rf /etc/kubernetes/ /var/lib/etcd/ /var/lib/kubelet/ /var/lib/dockershim/ /var/run/kubernetes/

# Purge Kubernetes packages
echo "Purging Kubernetes packages..."
sudo apt-get purge kubeadm kubectl kubelet kubernetes-cni kube* -y

# Remove unused dependencies
echo "Removing unused dependencies..."
sudo apt-get autoremove -y

# Remove networking interfaces related to Kubernetes
echo "Deleting Kubernetes network interfaces..."
sudo ip link delete cni0 || echo "Interface cni0 not found, skipping..."
sudo ip link delete flannel.1 || echo "Interface flannel.1 not found, skipping..."
sudo ip link delete tunl0 || echo "Interface tunl0 not found, skipping..."

# Flush and clean up iptables rules
echo "Flushing and cleaning iptables..."
sudo iptables -F
sudo iptables -t nat -F
sudo iptables -t mangle -F
sudo iptables -X
sudo iptables -t nat -X
sudo iptables -t mangle -X
sudo iptables -Z

# Remove the Docker registry path
echo "Removing Docker registry path: $DOCKER_REGISTRY_PATH"
sudo rm -rf "$DOCKER_REGISTRY_PATH"
echo "Docker registry path removed."

echo "Kubernetes reset complete."
