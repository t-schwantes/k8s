#!/bin/bash

# Install Docker if it isn't already installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Installing Docker..."

    # Add Docker's official GPG key and install Docker
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update
#    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    sudo apt-get install -y docker-ce=5:27.3.1-1~ubuntu.22.04~jammy docker-ce-cli=5:27.3.1-1~ubuntu.22.04~jammy containerd.io=1.7.22-1
    echo "Docker installed successfully."
else
    echo "Docker is already installed."
fi
