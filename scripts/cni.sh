# Install Flannel (Control server)
echo "Installing Flannel network plugin..."

# Create the directory for Flannel binary
sudo mkdir -p /opt/bin/

# Download the Flannel binary
sudo curl -fsSLo /opt/bin/flanneld https://github.com/flannel-io/flannel/releases/download/v0.19.0/flanneld-amd64

# Make the Flannel binary executable
sudo chmod +x /opt/bin/flanneld

echo "Flannel installation complete."
