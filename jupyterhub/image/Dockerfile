# Use an official Node image to extract Node.js
# FROM node:16 as node-stage

# Use the Jupyter PyTorch notebook as the base image
FROM quay.io/jupyter/pytorch-notebook:latest

SHELL ["/bin/bash", "-c"]

# Switch to root to install system-level packages
USER root

COPY default-config/bashrc /home/jovyan/.bashrc
COPY default-config/bash_profile /home/jovyan/.bash_profile
# Fix ownership of the bash files
RUN chown ${NB_UID}:${NB_GID} /home/jovyan/.bashrc && \
    chown ${NB_UID}:${NB_GID} /home/jovyan/.bash_profile

# Install Python packages and system-level dependencies, then clean up
COPY requirements.txt /tmp/
RUN pip install -r /tmp/requirements.txt && rm /tmp/requirements.txt && \
    apt-get update && apt-get install -y build-essential npm nodejs&& \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy Node.js and npm from the Node image stage
# COPY --from=node-stage /usr/local /usr/local

# Tensorboard setup
RUN mkdir -p /etc/tb/
RUN fix-permissions /etc/tb/
COPY init /usr/local/bin/
RUN chmod 755 /usr/local/bin/init
RUN mkdir -p /app
RUN fix-permissions /app
WORKDIR /etc/tb/
RUN npm install http-proxy --save
COPY tensorboard-proxy.js /etc/tb/
WORKDIR "${HOME}"

# Set back to the default Jupyter user (jovyan)
USER ${NB_UID}

ENTRYPOINT ["/bin/bash", "-c", "node /etc/tb/tensorboard-proxy.js & start-notebook.sh"]

# Optional: Add environment variables or other configurations if needed
# ENV CUSTOM_ENV_VAR=custom_value

# You can also add Jupyter extensions or other customizations here
# RUN jupyter labextension install <extension>

# Expose Jupyter's default port
EXPOSE 8888 6006

