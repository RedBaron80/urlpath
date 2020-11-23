#!/bin/bash
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install unzip docker.io -y
# Downloading the software
wget https://github.com/RedBaron80/urlpath/archive/master.zip
unzip master.zip
# Installing kubernetes k3s
curl -sfL https://get.k3s.io | sh -
# Permissions
sudo chown ubuntu /etc/rancher/k3s/k3s.yaml
# sudo usermod -aG docker ubuntu # we would have to log out and log in again
sudo docker build urlpath-master/httpd-proxy -t httpd-proxy:1.0
sudo docker build urlpath-master/urlpath-django -t urlpath:1.0
# Importing images to k3s local registry
sudo docker save --output urlpath.tar urlpath:1.0
# Applying kubernetes configuration
kubectl apply -f urlpath-master/kubernetes/urlpath-deployment.yaml
sudo docker save --output httpd-proxy.tar httpd-proxy:1.0
sudo k3s ctr images import httpd-proxy.tar
kubectl apply -f urlpath-master/kubernetes/httpd-proxy-deployment.yaml
sudo k3s ctr images import urlpath.tar
kubectl apply -f urlpath-master/kubernetes/urlpath-deployment.yaml
kubectl apply -f urlpath-master/kubernetes/httpd-proxy-service.yaml
kubectl apply -f urlpath-master/kubernetes/urlpath-service.yaml
kubectl apply -f urlpath-master/kubernetes/ingress.yaml
echo "Done!!"