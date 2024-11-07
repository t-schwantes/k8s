#!/bin/bash

# Check if username and password are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <username> <password>"
    exit 1
fi

USERNAME=$1
PASSWORD=$2

# Encode username and password for Kubernetes secret
USERNAME_ENCODED=$(echo -n ${USERNAME} | base64)
PASSWORD_ENCODED=$(echo -n ${PASSWORD} | base64)

# SSH details
SYN_HOST="192.168.0.102" # Replace with your Synology IP
SYN_USER="qb" # Replace with your Synology admin username

ssh ${SYN_USER}@${SYN_HOST} <<EOF
if [ ! -d "/volume1/ml-storage/users/${USERNAME}" ]; then
    echo "Creating user ${USERNAME} on Synology..."
    if sudo synouser --add ${USERNAME} ${PASSWORD} "New user created via SSH" 0 "" 0; then
        sudo mkdir -p /volume1/ml-storage/users/${USERNAME}
        sudo chown jupyter /volume1/ml-storage/users/${USERNAME}
        
        sudo synoacltool -add /volume1/ml-storage/users/${USERNAME} user:${USERNAME}:allow:rwxpdDaARWc--:fd--
        sudo synoacltool -add /volume1/ml-storage/users/${USERNAME} group:users:allow:r-x---a-R-c--:fd--
        sudo synoacltool -add /volume1/ml-storage/users/${USERNAME} group:administrators:allow:rwxpdDaARWc--:fd--
    else
        echo "Failed to create user ${USERNAME}. It may already exist or an error occurred."
    fi
else
    echo "User directory for ${USERNAME} already exists, assuming user exists on Synology."
fi
EOF

# Feedback to user
if [ $? -eq 0 ]; then
    echo "User ${USERNAME} created and folder permissions set successfully."
else
    echo "Failed to create user or set permissions."
    exit 1
fi

# Generate Kubernetes YAML file from template
TEMPLATE_FILE="jupyterhub/storage/user-template.yaml"
OUTPUT_FILE="jupyterhub/storage/user-yamls/synology-storage-${USERNAME}.yaml"

sed -e "s/{username}/${USERNAME}/g" \
    -e "s/{username_encoded}/${USERNAME_ENCODED}/g" \
    -e "s/{password_encoded}/${PASSWORD_ENCODED}/g" \
    ${TEMPLATE_FILE} > ${OUTPUT_FILE}

# Apply the generated YAML file to Kubernetes
kubectl apply -f ${OUTPUT_FILE}

# Feedback to user
if [ $? -eq 0 ]; then
    echo "Kubernetes resources for ${USERNAME} applied successfully."
else
    echo "Failed to apply Kubernetes resources for ${USERNAME}."
    exit 1
fi

# Retrieve the JupyterHub API token from Kubernetes Secret
JUPYTERHUB_API_TOKEN=$(kubectl get secret jupyterhub-api-token -o jsonpath="{.data.token}" | base64 --decode)
JUPYTERHUB_URL="http://192.168.0.127/hub/api" # Replace with your JupyterHub URL

# Add user to JupyterHub
curl -X POST ${JUPYTERHUB_URL}/users/${USERNAME} \
    -H "Authorization: Bearer ${JUPYTERHUB_API_TOKEN}" \
    -H "Content-Type: application/json" \
    --data '{"admin": false}'

# Feedback to user
if [ $? -eq 0 ]; then
    echo "User ${USERNAME} added to JupyterHub successfully."
else
    echo "Failed to add user ${USERNAME} to JupyterHub."
fi
