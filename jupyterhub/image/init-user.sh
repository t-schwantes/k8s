#!/bin/bash

# Directory of the user's home
USER_HOME="/home/jovyan"

# Check and copy default .bashrc if it doesn't exist
if [ ! -f "${USER_HOME}/.bashrc" ]; then
    cp /etc/skel/.bashrc "${USER_HOME}/.bashrc"
fi

# Check and copy default .bash_profile if it doesn't exist
if [ ! -f "${USER_HOME}/.bash_profile" ]; then
    cp /etc/skel/.bash_profile "${USER_HOME}/.bash_profile"
fi

# Ensure the ownership of the files belongs to the user
chown jovyan:users "${USER_HOME}/.bashrc" "${USER_HOME}/.bash_profile"
