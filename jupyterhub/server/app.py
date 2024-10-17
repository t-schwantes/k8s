from flask import Flask, render_template
from kubernetes import client, config

app = Flask(__name__)

def get_pod_info():
    # Load Kubernetes configuration
    config.load_incluster_config()

    # Initialize the API client
    v1 = client.CoreV1Api()

    # Get the list of pods in the jupyterhub namespace
    pods = v1.list_namespaced_pod(namespace="jupyterhub").items

    pod_data = []
    for pod in pods:
        # Filter out the jupyterhub-dashboard pod
        if pod.metadata.name.startswith("jupyter") and not pod.metadata.name.startswith("jupyterhub-dashboard"):
            gpu_count = 0
            containers = pod.spec.containers
            for container in containers:
                if container.resources and container.resources.limits:
                    gpu_count += int(container.resources.limits.get("nvidia.com/gpu", 0))
            node_name = pod.spec.node_name
            pod_data.append({
                "name": pod.metadata.name,
                "status": pod.status.phase,
                "node": node_name,
                "gpus": gpu_count
            })
    return pod_data

@app.route('/dashboard')
def dashboard():
    data = get_pod_info()
    return render_template('dashboard.html', data=data)

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8080)
