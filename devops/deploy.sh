#!/bin/bash

# Magical colors
green='\e[0;32m'
yellow='\e[0;33m'
red='\e[0;31m'
blue='\e[0;34m'
endColor='\e[0m'

date

echo -e "${yellow}1. Creating and configuring new Kubernetes cluster - configured gcloud cli is required${endColor}"
type gcloud >/dev/null 2>&1 || { echo -e >&2 "${red}I require gcloud but it's not installed.  Aborting.${endColor}"; exit 1; }

echo -e "${blue}Cluster provisioning - it can take a few minutes${endColor}"
# terraform should be here instead of gcloud
gcloud container clusters create gocluster
echo -e "${green}Done${endColor}"

echo -e "${blue}Cluster node tagging${endColor}"
# tag nodes - 1 loadbalancer, 2 webservers
nodes=$(kubectl get no | grep -v ^NAME | awk '{print $1}')
kubectl label nodes --overwrite=true $(echo $nodes | awk '{print $1}') role=loadbalancer
kubectl label nodes --overwrite=true $(echo $nodes | awk '{print $2}') role=webserver
kubectl label nodes --overwrite=true $(echo $nodes | awk '{print $3}') role=webserver
echo -e "${green}Done${endColor}"

echo -e "${blue}Cluster firewall configuration${endColor}"
gcloud compute firewall-rules delete -q $(gcloud compute firewall-rules list | grep -v ^NAME | awk '{print $1}') || true 
gcloud compute firewall-rules create insecure-allow-all --allow tcp:0-65535,udp:0-65535,icmp --source-ranges 0.0.0.0/0
echo -e "${green}Done${endColor}"

echo -e "${yellow}2. Deploying dockerized go-app infrastructure${endColor}"

echo -e "${blue}Kubernetes services and replication controllers${endColor}"
kubectl create -f all-in-one.yaml
echo -e "${green}Done${endColor}"

echo -e "${blue}List current pod (containers)${endColor}"
# list pods
kubectl get po
echo -e "${green}Done${endColor}"

echo -e "${blue}Scale up rc go-app${endColor}"
# scale up - defaul replicas in yaml is only 3
kubectl scale rc goapp --replicas=6
echo -e "${green}Done${endColor}"

echo -e "${blue}List current pod (containers)${endColor}"
# list pods
sleep 10
kubectl get po
echo -e "${green}Done${endColor}"

echo -e "${blue}Quick rolling update - to jangaraj/go-app:10${endColor}"
# list pods
kubectl rolling-update goapp --image=jangaraj/go-app:10 --timeout=20s --update-period=1s
echo -e "${green}Done${endColor}"
date

echo -e "${blue}Get loadbalancer public IP${endColor}"
# find public ip of loadbalancer node
LB=$(echo $nodes | awk '{print $1}')
IP=$(gcloud compute instances list | grep $(echo $nodes | awk '{print $1}') | awk '{print $5}')
echo -e "${green}App: http://${IP}/goapp${endColor}"
echo -e "${green}Haproxy stats: http://${IP}:1936${endColor}"
echo -e "${green}Watch command: watch -n 0.1 curl -qs $IP/goapp${endColor}"
echo -e "${green}Stress test: siege -c 100 -t 30S -b http://${IP}/goapp${endColor}"
echo -e "--------------------------"
echo -e "${green}ssh loadbalancer: gcloud compute ssh $LB${endColor}"
echo -e "${green}apt-get update; apt-get install -y siege${endColor}"
echo -e "${green}Stress test: siege -c 100 -t 30S -b http://127.0.0.1/goapp${endColor}"
