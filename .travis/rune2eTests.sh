#!/usr/bin/env bash
set -x

# Confirm we're working
kubectl get all --all-namespaces
kubectl get ingress --all-namespaces
minikube ip

#- sleep 30
curl $(minikube ip)/api/services
for i in {1..10}; do curl $(minikube ip)/api/services; echo ""; sleep 2; done
curl $(minikube ip)/api/services --output fud.txt
ls -alF
grep jaeger-query fud.txt
