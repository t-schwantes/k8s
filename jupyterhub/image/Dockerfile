# Use an official Node image to extract Node.js
# FROM node:16 as node-stage

# Use the Jupyter PyTorch notebook as the base image
# FROM quay.io/jupyter/pytorch-notebook:latest
FROM quay.io/jupyter/pytorch-notebook:cuda12-python-3.11

SHELL ["/bin/bash", "-c"]

# Switch to root to install system-level packages
USER root

# ----------------------------------------------
# Adjust jovyan user and sudo
RUN echo "jovyan:Abcd1234" | chpasswd
RUN sed -i -e 's/^#%admin/%admin/' /etc/sudoers && \
    sed -i -e 's/^#%sudo/%sudo/' /etc/sudoers
RUN echo "jovyan ALL=(ALL:ALL) ALL" >> /etc/sudoers
RUN echo "jovyan ALL=(root) NOPASSWD: /usr/sbin/sshd" >> /etc/sudoers

# Copy default bash files into /etc/skel
COPY default-config/bashrc /etc/skel/.bashrc
COPY default-config/bash_profile /etc/skel/.bash_profile
# Fix ownership of /etc/skel (ensure permissions are correct)
RUN chown -R root:root /etc/skel && \
    chmod 644 /etc/skel/.bashrc /etc/skel/.bash_profile

# Install Python packages and system-level dependencies, then clean up
COPY requirements.txt /tmp/
RUN pip install kubernetes ipyevents
RUN pip install -r /tmp/requirements.txt && rm /tmp/requirements.txt && \
    apt-get update && apt-get install -y build-essential npm nodejs htop btop && \
    apt-get install build-essential cmake git libavcodec-dev libavformat-dev -y && \
    apt-get install libswscale-dev libgstreamer-plugins-base1.0-dev libgstreamer1.0-dev -y && \
    apt-get install libgtk-3-dev libpng-dev libjpeg-dev libopenexr-dev libtiff-dev libwebp-dev -y && \
    apt-get install libopencv-dev x264 libx264-dev libssl-dev ffmpeg -y && \
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

# Copy init script to copy default bash configurations for users
RUN mkdir -p /home/jovyan/.conda/pkgs && chmod 777 /home/jovyan/.conda/pkgs
COPY init-user.sh /usr/local/bin/init-user.sh
RUN chmod +x /usr/local/bin/init-user.sh

# Set back to the default Jupyter user (jovyan)
USER ${NB_UID}

# Run the user initialization script on startup before the notebook starts
ENTRYPOINT ["/bin/bash", "-c", "/usr/local/bin/init-user.sh && node /etc/tb/tensorboard-proxy.js & start-notebook.sh"]

# Optional: Add environment variables or other configurations if needed
# ENV CUSTOM_ENV_VAR=custom_value

# You can also add Jupyter extensions or other customizations here
# RUN jupyter labextension install <extension>

# Expose Jupyter's default port
EXPOSE 8888 6006

