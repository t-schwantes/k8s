# pre-config
Set the control node to have passwordless ssh access and passwordless sudo access on all the worker nodes and the synology storage server
This allows the control node to install and setuup the worker machines, and allows it to manage storage permissions on the storage server

on control node: 
ssh-keygen -t rsa -b 4096
ssh-copy-id <user>@<worker-node-ip>
sudo visudo 
comment out this line: \# %sudo   ALL=(ALL:ALL) ALL 
add this line: %sudo   ALL=(ALL:ALL) NOPASSWD: ALL

on synology storage server enable home services
go to control panel -> user & group -> advanced at the bottom click enable user home service
copy over ssh key 
edit /etc/sudoers.d to have passwordless sudo
also synology setup must be done on the synology server, stuff like creating the share and permissions
the share folders should be owned by a user with uid 1000 and gid 100 because thats what jupyterhub logs in as
The individual folders should have permissions added that let the user read/write (the add user script does this)

# Main script setup-k8s
This script calls all the other scripts, run it in the directory it is located (./setup-k8s.sh) it does pathing from there
The config.sh script holds variables that can be modifed things like the main server ip address, what the ip address of jupyterhub is etc




# After setup
Add kubernetes api token if you want to add users via the script
go to jupyterhub, click on token, generate api token
kubectl create secret generic jupyterhub-api-token --from-literal=token="<api-token>"
./scripts/jupyterhub/add-user.sh <username> <password>



# Script information

## config-system
Some things needed to be changed to get it to work on ubunto 22.04
see documentation/WebPageBackups/Solved_This Week In Tech...

Updates package list
turns off swap memory and disables it
loads modprobe overlay and br_netfliter and makes them load on boot
sets up ip tables for networking

## install /
- docker: if already installed it skips (docker-ce=5:27.3.1-1\~ubuntu.22.04~jammy docker-ce-cli=5:27.3.1-1\~ubuntu.22.04~jammy containerd.io=1.7.22-1)
- containerd: Must be reran on install because it also configures /etc/containerd/config.toml to allow SystemCgroup (containerd.io=1.7.22-1)
- kubernetes: kubelet, kubeadm, kubectl (1.31.1)
- cni: Stands for container network interface, used flanneld, calico didn't work initially for some reason 
- nvidia-container: nvidia-container-toolkit (1.17.0-1) it also configures containerd to be the default runtime

# k8s /
## - init 
Inits the kubeadm cluster 
copies the config to the users home directory and sets permissions
removes taints on control node (allows the control node to be scheduled for jobs)
## - cni
applies (container network interface) flanneld that enables networking between nodes and stuff
## - Worker
copies install scripts over to the worker node and installs everything
prints the join command and joins the cluster
also modifies docker daemon to enable unsecure access to control node docker registry

# Docker / registry
creates registry directory at the path and sets permissions
sets up from template and applies pvc and deployment (continuously running pod in charge of the registry)
waits for the deployment to be running
updates containerd config to include insecure registry (http @ controle plane node ip address)
updates docker daemon to allow insecure registry @ control plane node ip address

# jupyterhub \
## build-image
builds the image, tags it as base:latest, pushes it to the registry on the control plane node
The image is custom and has a tensorboard-proxy script copied over onto it
it also copies over some default config stuff like text color in terminal

## init
creates jupyterhub namespace in kubernetes
installs helm
helm installs jupyterhub (4.0.0) and nvidia gpu operator (24.9.0)
patches jupyterhub proxy to whatever ip address was put in the config.sh

## storage
installs nfs-kernel-server (1:2.6.1-1ubuntu1.2)
creates the storage path and modifies permissions
configures /etc/exports to make the storage mountable by other nodes I think
creates pvc and pv from templates and applies them
creates pod-manager-role and rolebindings so the jupyterhub kernels can access kubernetes information (which nodes are being used)
helm installs csi-driver-smb which is required for synology user storage

## dashboard-server
builds the dashboard server image, tags it, pushes it to the registry
the server is a flask app run on the image
creates a deployment for the dashboard server and applies it to continuously run

## tensorboard
Builds a container that handles the routing for tensorboard 
creates a deployment and applies it
(and routing the dashboard server as well, hmmmmmm)



