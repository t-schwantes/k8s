# Use the Jupyter PyTorch notebook as the base image
FROM quay.io/jupyter/pytorch-notebook:latest

SHELL ["/bin/bash", "-c"] 

# Switch to root to install system-level packages
USER root

COPY bashrc /home/jovyan/.bashrc
COPY bash_profile /home/jovyan/.bash_profile
# Fix ownership of the bash files
RUN chown ${NB_UID}:${NB_GID} /home/jovyan/.bashrc && \
    chown ${NB_UID}:${NB_GID} /home/jovyan/.bash_profile

# Install Python packages and system-level dependencies, then clean up
COPY requirements.txt /tmp/
RUN pip install -r /tmp/requirements.txt && rm /tmp/requirements.txt && \
    apt-get update && apt-get install -y build-essential && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set back to the default Jupyter user (jovyan)
USER ${NB_UID}

# Optional: Add environment variables or other configurations if needed
# ENV CUSTOM_ENV_VAR=custom_value

# You can also add Jupyter extensions or other customizations here
# RUN jupyter labextension install <extension>

# Expose Jupyter's default port
EXPOSE 8888
