# Apply Flannel network configuration
echo "Applying Flannel network configuration..."

#kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
kubectl apply -f k8s/cni/kube-flannel.yml

echo "Flannel network configuration applied."
