#!/bin/bash

source config.sh

echo 'adding user trevor-schwantes'
kubectl apply -f jupyterhub/storage/user-yamls/synology-storage-trevor-schwantes.yaml
echo 'adding user matthew-arnold'
kubectl apply -f jupyterhub/storage/user-yamls/synology-storage-matthew-arnold.yaml
