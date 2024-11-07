# k8s
kubernetes setup


kubectl create secret generic jupyterhub-api-token --from-literal=token="d37a2fb36fdd4e86a60fe8c9b697570b"
Put the jupyterhub token in there. this allows us to add users to jupyterhub with the script, unfortunatly the api token
needs to be created manully and so we have to enter it in manually
