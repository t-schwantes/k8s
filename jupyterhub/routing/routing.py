import requests
import subprocess
import time


from kubernetes import client, config
import base64
import requests
import time

# Load the Kubernetes configuration from within the pod
config.load_incluster_config()

# Kubernetes client
v1 = client.CoreV1Api()

# Get the JupyterHub secret token
def get_token():
    secret = v1.read_namespaced_secret("hub", "jupyterhub")
    token = base64.b64decode(secret.data["hub.config.ConfigurableHTTPProxy.auth_token"]).decode("utf-8")
    return token


node_port = 32123
#api_url = 'http://localhost:' + \
#    str(node_port) + '/api/routes'
#api_url = 'http://proxy-api-nodeport.jupyterhub.svc.cluster.local:8001/api/routes'
api_url = 'http://jupyterhub-routing-api.jupyterhub.svc.cluster.local:8001/api/routes'
token_descriptor = "hub.config." + \
    "ConfigurableHTTPProxy.auth_token"

#def get_token():
#    cmd = ["kubectl", "get", "secret", "hub",
#        "-n", "jupyterhub", "-o=json"]
#    p1 = subprocess.run(cmd, stdout=subprocess.PIPE)
#    cmd = ["jq", "-r", ".[\"data\"] | " +
#        ".[\"" + token_descriptor + "\"]"]
#    p2 = subprocess.run(cmd, stdout=subprocess.PIPE,
#        input=p1.stdout)
#    cmd = ["base64", "--decode"]
#    p3 = subprocess.run(cmd, stdout=subprocess.PIPE,
#        input=p2.stdout)
#    return p3.stdout.decode()

token = ""
while len(token) == 0:
    token = get_token()
    time.sleep(10)
print('token:', token)


# Add a route for /dashboard
def add_dashboard_route():
    dashboard_target = 'http://jupyterhub-dashboard.jupyterhub.svc.cluster.local:8080'
    res = requests.post(
        api_url + '/dashboard/',
        headers={
            'Authorization': 'token %s' % token
        },
        json={
            'target': dashboard_target,
            'jupyterHub': False
        }
    )
    print('Dashboard route post:', res)

# Call this function to add the dashboard route when setting up the routes
add_dashboard_route()

def get_routes():
    r = requests.get(api_url,
        headers={
            'Authorization': 'token %s' % token,
            }
        )
    r.raise_for_status()
    routes = r.json()
    return routes

def post_route(token=None, user=None, target=None, path=None):
    res = requests.post(
        api_url + '/user/' + user + '/' + path + '/',
        headers={
            'Authorization': 'token %s' % token
        },
        json={
            'user': user,
            'target': target,
            'jupyterHub': True
        }
    )
    print('route post:', res)

while True:
    time.sleep(1)
    
    try:
        routes = get_routes()
    except Exception as e:
        print(e)
        print('failed to get routes')
        continue

    try:
        for key in routes.keys():
            items = key.split('/')
            tb_path = len(items) > 3 and 'tb' in items[3]
            if items[1] == 'user' and not tb_path:
                user = routes[key]['user']
                target = 'http:' + \
                    routes[key]['target'].split(':')[1] + ':'
                post_route(token, user, target + '6116', 'tb')
                post_route(token, user, target + '6117', 'tb6007')
                post_route(token, user, target + '6118', 'tb6008')
    except:
        print('failed to update routes')

    time.sleep(30)
