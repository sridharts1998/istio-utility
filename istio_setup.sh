#!/bin/bash

# Remove taint from control-plane node (for dev/test use only)
# In this environment, the control-plane node has more resources,
# so workloads are scheduled on it. You can skip this step if your worker nodes have sufficient capacity.
kubectl taint nodes $(kubectl get nodes --no-headers | grep -i control | awk '{print $1}') node-role.kubernetes.io/control-plane- || true

set -euo pipefail

# Install istioctl CLI
curl -L https://istio.io/downloadIstio | sh -
export PATH="$PATH:$HOME/istio-1.26.2/bin"

# Install Helm
curl -sSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Add Istio Helm repo
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update

# Create istio-system namespace
kubectl create namespace istio-system || true

# Install Istio base components
helm install istio-base istio/base -n istio-system

# Install Istio control plane
helm install istiod istio/istiod -n istio-system \
  --set global.istioNamespace=istio-system

# Install Istio ingress gateway
helm install istio-ingress istio/gateway -n istio-system

# Wait for LoadBalancer hostname
while [[ -z "$(kubectl get svc istio-ingress -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)" ]]; do
  sleep 5
done

ALB_HOSTNAME=$(kubectl get svc istio-ingress -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "ALB Ready: http://$ALB_HOSTNAME/productpage"

# Create bookinfo namespace and enable sidecar injection
kubectl create namespace bookinfo || true
kubectl label namespace bookinfo istio-injection=enabled --overwrite

# Deploy Bookinfo application
kubectl apply -n bookinfo -f https://raw.githubusercontent.com/istio/istio/release-1.21/samples/bookinfo/platform/kube/bookinfo.yaml

# Apply Gateway and VirtualService
kubectl apply -n bookinfo -f https://raw.githubusercontent.com/istio/istio/release-1.21/samples/bookinfo/networking/bookinfo-gateway.yaml

# Patch Gateway selector and port
kubectl patch gateway bookinfo-gateway -n bookinfo --type=json \
  -p='[{"op": "replace", "path": "/spec/selector/istio", "value":"ingress"}]'

kubectl patch gateway bookinfo-gateway -n bookinfo --type=json \
  -p='[{"op": "replace", "path": "/spec/servers/0/port/number", "value": 80}]'

# Apply Telemetry for access logging
kubectl apply -f telemetry-access-logging.yaml

echo "Setup complete."
echo "Bookinfo available at: http://$ALB_HOSTNAME/productpage"
