#!/usr/bin/env bash
set -x

env | sort

# Confirm we're working
kubectl get all --all-namespaces
minikube ip

docker build -t kearls/hello-minikube ./example/
kubectl create -f example/deploy.yaml
sleep 20
docker images
kubectl get pods
