#!/usr/bin/env bash
#set -x

# Confirm we're working
kubectl get all --all-namespaces
kubectl get ingress --all-namespaces
minikube ip

# Loop as it sometimes takes a few seconds for the first trace to show up
for i in {1..10}; do curl $(minikube ip)/api/services; echo ""; sleep 2; done

