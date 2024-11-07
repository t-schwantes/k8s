#!/bin/bash

# Synology credentials (admin account)
SYNOLOGY_IP="192.168.0.102"
ADMIN_USER="qb"
ADMIN_PASSWORD="Abcd1234" # Simplify this temporarily to test if that resolves the issue

# New user information
NEW_USER="default"
NEW_PASSWORD="Abcd1234"
NEW_USER_GROUP="users" # The group you want to add the user to

# Authenticate and get a session ID using POST
RESPONSE=$(curl -k -X POST "http://${SYNOLOGY_IP}:5000/webapi/auth.cgi" \
  --data-urlencode "account=${ADMIN_USER}" \
  --data-urlencode "passwd=${ADMIN_PASSWORD}" \
  --data-urlencode "api=SYNO.API.Auth" \
  --data-urlencode "version=3" \
  --data-urlencode "method=login" \
  --data-urlencode "session=FileStation" \
  --data-urlencode "format=sid")

# Extract the session ID from the response
SID=$(echo $RESPONSE | jq -r '.data.sid')

# Check if authentication was successful
if [ "$SID" == "null" ] || [ -z "$SID" ]; then
    echo "Authentication failed. Response: $RESPONSE"
    exit 1
fi
echo "Authentication successful. SID: $SID"

# Create a new user using POST
CREATE_USER_RESPONSE=$(curl -k -X POST "http://${SYNOLOGY_IP}:5000/webapi/entry.cgi" \
  --data-urlencode "api=SYNO.Core.User" \
  --data-urlencode "version=3" \
  --data-urlencode "method=create" \
  --data-urlencode "name=${NEW_USER}" \
  --data-urlencode "password=${NEW_PASSWORD}" \
  --data-urlencode "group=${NEW_USER_GROUP}" \
  --data-urlencode "_sid=${SID}")

# Output the response of the create user request
echo "Create user response: $CREATE_USER_RESPONSE"

# Check if the user was successfully created
USER_CREATION_SUCCESS=$(echo $CREATE_USER_RESPONSE | jq -r '.success')
if [ "$USER_CREATION_SUCCESS" != "true" ]; then
    ERROR_CODE=$(echo $CREATE_USER_RESPONSE | jq -r '.error.code')
    echo "User creation failed. Error code: $ERROR_CODE, Response: $CREATE_USER_RESPONSE"
    exit 1
else
    echo "User '${NEW_USER}' created successfully."
fi

# Logout after creating the user
LOGOUT_RESPONSE=$(curl -k -X GET "http://${SYNOLOGY_IP}:5000/webapi/auth.cgi?api=SYNO.API.Auth&version=3&method=logout&session=FileStation&_sid=${SID}")
echo "Logout response: $LOGOUT_RESPONSE"

