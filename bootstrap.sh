#!/usr/bin/env bash
set -euo pipefail

# Run from the repository root.
# Requires Docker, kind, kubectl, and Helm.

CLUSTER_NAME="${CLUSTER_NAME:-task12}"
CONTEXT="kind-${CLUSTER_NAME}"
CHART_PATH="./helm-chart/todoapp"

# Create a separate cluster to avoid conflicts with resources from earlier tasks.
if ! kind get clusters | grep -qx "${CLUSTER_NAME}"; then
  kind create cluster --name "${CLUSTER_NAME}" --config cluster.yml
fi

kubectl --context "${CONTEXT}" cluster-info
kubectl --context "${CONTEXT}" get nodes --show-labels

# Label and taint MySQL nodes if the cluster configuration provides them.
while IFS= read -r node; do
  [ -n "$node" ] || continue
  kubectl --context "${CONTEXT}" taint nodes "$node" app=mysql:NoSchedule --overwrite
done < <(kubectl --context "${CONTEXT}" get nodes -l app=mysql -o name | sed 's#node/##')

# Install the ingress controller prerequisite.
kubectl --context "${CONTEXT}" apply -f \
  https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Build and validate the Helm chart and its MySQL dependency.
helm dependency build "${CHART_PATH}"
helm lint "${CHART_PATH}"
helm lint "${CHART_PATH}/charts/mysql"

# Install or upgrade the application and its MySQL subchart.
helm upgrade --install todoapp "${CHART_PATH}" \
  --kube-context "${CONTEXT}" \
  --namespace todoapp \
  --create-namespace \
  --wait \
  --timeout 5m

# Show deployment status.
kubectl --context "${CONTEXT}" get pods -A -o wide
kubectl --context "${CONTEXT}" get statefulset -n mysql
kubectl --context "${CONTEXT}" get deployment -n todoapp

# Save the required resource inventory in the repository root.
kubectl --context "${CONTEXT}" get all,cm,secret,ing -A | tee output.log

echo "Deployment complete. Resource inventory saved to output.log"