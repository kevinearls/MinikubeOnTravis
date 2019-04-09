#!/usr/bin/env bash
set -x

# Confirm we're working
kubectl get all --all-namespaces
minikube ip

docker build -t kearls/hello-minikube -f example/Dockerfile
kubectl create -f example/deploy.yaml
sleep 20
kubectl get pods
