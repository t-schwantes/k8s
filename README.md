# k8s
kubernetes setup
./setup_control.sh

After setup
Add kubernetes api token if you want to add users via the script
go to jupyterhub, click on token, generate api token
kubectl create secret generic jupyterhub-api-token --from-literal=token="<api-token>"
./scripts/jupyterhub/add-user.sh <username> <password>
