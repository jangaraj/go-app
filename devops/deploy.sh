#!/bin/bash

type gcloud >/dev/null 2>&1 || { echo >&2 "I require gcloud but it's not installed.  Aborting."; exit 1; }

# terraform should be here instead of gcloud
gcloud container clusters create gocluster

# tag nodes - 1 loadbalancer, 2 webservers
nodes=$(kubectl get no | grep -v ^NAME | awk '{print $1}')
kubectl label nodes --overwrite=true $(echo $nodes | awk '{print $1}') role=loadbalancer
kubectl label nodes --overwrite=true $(echo $nodes | awk '{print $2}') role=webserver
kubectl label nodes --overwrite=true $(echo $nodes | awk '{print $3}') role=webserver

# list pods
kubectl get po

# scale up - defaul replicas in yaml is only 1
kubectl scale rc goapp --replicas=6

# list pods
kubectl get po

# find public ip of loadbalancer node
gcloud compute instances list | grep $(echo $nodes | awk '{print $1}') | awk '{print $5}'