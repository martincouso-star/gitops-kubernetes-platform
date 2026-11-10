#!/usr/bin/env bash
# Render Helm charts and Kustomize overlays into build/manifests for kubeconform.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="${ROOT}/build/manifests"
mkdir -p "${OUT}"
cd "${ROOT}"

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx >/dev/null
helm repo add jetstack https://charts.jetstack.io >/dev/null
helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/ >/dev/null
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts >/dev/null
helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts >/dev/null
helm repo update >/dev/null

render_chart() {
  local release="$1"
  local repo="$2"
  local chart="$3"
  local version="$4"
  local namespace="$5"
  local env="$6"
  local values_dir="$7"

  helm template "${release}" "${repo}/${chart}" \
    --version "${version}" \
    --namespace "${namespace}" \
    --values "${values_dir}/values.yaml" \
    --values "${values_dir}/values-${env}.yaml" \
    > "${OUT}/${release}-${env}.yaml"
}

for env in local dev prod; do
  render_chart ingress-nginx ingress-nginx ingress-nginx 4.15.1 ingress-nginx "${env}" gitops/platform/ingress-nginx
  render_chart cert-manager jetstack cert-manager v1.21.3 cert-manager "${env}" gitops/platform/cert-manager
  render_chart external-dns external-dns external-dns 1.23.0 external-dns "${env}" gitops/platform/external-dns
  render_chart kube-prometheus-stack prometheus-community kube-prometheus-stack 93.1.1 monitoring "${env}" gitops/platform/monitoring
  render_chart gatekeeper gatekeeper gatekeeper 3.23.1 gatekeeper-system "${env}" gitops/platform/gatekeeper
  kustomize build "gitops/workloads/sample-app/overlays/${env}" > "${OUT}/sample-app-${env}.yaml"
  kustomize build "gitops/platform/platform-config/overlays/${env}" > "${OUT}/platform-config-${env}.yaml"
  kustomize build "gitops/clusters/${env}" > "${OUT}/cluster-${env}.yaml"
done

kustomize build gitops/platform/namespaces > "${OUT}/namespaces.yaml"
kustomize build gitops/platform/gatekeeper/policies > "${OUT}/gatekeeper-policies.yaml"
cp gitops/bootstrap/root-dev.yaml "${OUT}/root-dev.yaml"
cp gitops/bootstrap/root-prod.yaml "${OUT}/root-prod.yaml"
cp gitops/bootstrap/root-local.yaml "${OUT}/root-local.yaml"

echo "Rendered manifests in ${OUT}"
