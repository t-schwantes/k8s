FROM python:3.9-buster

# Update package lists and install Flask
RUN apt-get update && apt-get install -y && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy the current directory contents to /app in the container
COPY . /app

# Install required Python packages
RUN pip install --no-cache-dir Flask kubernetes

# Expose port 8080 for the Flask app
EXPOSE 8080

# Run the Flask app
CMD ["python", "/app/app.py"]

