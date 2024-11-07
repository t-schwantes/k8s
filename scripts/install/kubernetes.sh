# Check if kubeadm is installed before proceeding
if ! command -v kubeadm &> /dev/null; then
    echo "Kubernetes (kubeadm, kubelet, kubectl) is not installed. Installing..."

    # Install necessary packages for Kubernetes
    sudo apt-get install -y apt-transport-https ca-certificates curl

    # Add Kubernetes GPG key
    sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://dl.k8s.io/apt/doc/apt-key.gpg

    # Add Kubernetes repository for Ubuntu
    echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

    # Update package lists to include Kubernetes repository
    sudo apt-get update

    # Specify the current versions for Kubernetes components
    KUBE_VERSION="1.31.1-00"

    # Install Kubernetes components with the specified version
    echo "Installing kubelet, kubeadm, and kubectl..."
    sudo apt-get install -y kubelet=${KUBE_VERSION} kubeadm=${KUBE_VERSION} kubectl=${KUBE_VERSION}

    # Prevent kubelet, kubeadm, and kubectl from being automatically updated
    sudo apt-mark hold kubelet kubeadm kubectl
    echo "Kubernetes installation complete."
else
    echo "Kubernetes components are already installed."
fi
