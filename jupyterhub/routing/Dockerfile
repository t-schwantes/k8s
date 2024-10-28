FROM python:3.10

# Install necessary packages
RUN apt-get update && \
    apt-get install -y jq && \
    apt-get clean

# Install kubectl
RUN curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl

# Set the working directory
WORKDIR /app

# Copy the Python script into the container
COPY routing.py /app/routing.py

# Install Python dependencies
RUN pip install --upgrade pip && pip install requests kubernetes

# Command to run the Python script
CMD ["python", "/app/routing.py"]
