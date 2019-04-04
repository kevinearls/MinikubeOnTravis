#!/usr/bin/env bash
set -x
# Download kubectl, which is a requirement for using minikube.
curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/v1.13.0/bin/linux/amd64/kubectl && chmod +x kubectl && sudo mv kubectl /usr/local/bin/
# Download minikube.
curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.35.0/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
mkdir -p $HOME/.kube $HOME/.minikube
touch $KUBECONFIG
sudo minikube start --vm-driver=none --kubernetes-version=v1.13.0
id
sudo chown -R travis: /home/travis/.minikube/
sudo minikube addons enable ingress

# TODO do we need to install the operator here?  I don't think we need it for the tests
#./installOperator.sh
kubectl create namespace observability
kubectl create -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/crds/jaegertracing_v1_jaeger_crd.yaml
kubectl create -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/service_account.yaml
kubectl create -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/role.yaml
kubectl create -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/role_binding.yaml
kubectl create -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/operator.yaml

kubectl get deployment jaeger-operator --namespace observability

# Install ES and Cassandra....TODO change these to use Make;  Also, set timeouts on until loops!  Move this to test script?
kubectl create namespace storage
kubectl create --namespace storage --filename https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/test/elasticsearch.yml
until kubectl --namespace storage get statefulset elasticsearch --output=jsonpath='{.status.readyReplicas}' | grep --quiet 1; do sleep 5;echo "waiting for elasticsearch to be available"; kubectl get statefulsets --namespace storage; done

# install Cassandra
kubectl create --namespace storage --filename https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/test/cassandra.yml
until kubectl --namespace storage get statefulset cassandra --output=jsonpath='{.status.readyReplicas}' | grep --quiet 3; do sleep 5;echo "waiting for cassandra to be available"; kubectl get statefulsets --namespace storage; done

# TODO we also won't need this for the real tests, remove it
# install simple-prod
kubectl create --namespace storage --filename https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/examples/simple-prod.yaml
until kubectl --namespace storage get deployment simple-prod-query --output=jsonpath='{.status.readyReplicas}' | grep --quiet 1; do sleep 5;echo "waiting for jaeger simple-prod deployment to be available"; kubectl get deployments --namespace storage; done
