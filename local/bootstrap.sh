#!/usr/bin/env bash
# Create a kind cluster, install Argo CD, and point it at this repo via an in-cluster git server.
# This script never talks to AWS or GCP.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

CLUSTER_NAME="${CLUSTER_NAME:-gitops-platform}"
ARGOCD_VERSION="${ARGOCD_VERSION:-v3.6.1}"

need() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing '$1'. Install it and re-run. See the local quickstart in the README." >&2
    exit 1
  fi
}

need kind
need kubectl
need docker
need git

if ! docker info >/dev/null 2>&1; then
  echo "Docker is not reachable. Start it before running make local-up." >&2
  exit 1
fi

if kind get clusters | grep -qx "${CLUSTER_NAME}"; then
  echo "kind cluster ${CLUSTER_NAME} already exists. Reusing it."
else
  kind create cluster --name "${CLUSTER_NAME}" --config local/kind-config.yaml
fi

kubectl config use-context "kind-${CLUSTER_NAME}"

kubectl get namespace argocd >/dev/null 2>&1 || kubectl create namespace argocd
kubectl apply -n argocd --server-side --force-conflicts \
  -f "https://raw.githubusercontent.com/argoproj/argo-cd/${ARGOCD_VERSION}/manifests/install.yaml"

kubectl apply -f local/manifests/git-server.yaml

kubectl -n argocd rollout status deployment/argocd-server --timeout=300s
kubectl -n argocd rollout status deployment/argocd-repo-server --timeout=300s
if kubectl -n argocd get statefulset argocd-application-controller >/dev/null 2>&1; then
  kubectl -n argocd rollout status statefulset/argocd-application-controller --timeout=300s
else
  kubectl -n argocd rollout status deployment/argocd-application-controller --timeout=300s
fi
kubectl -n git-server rollout status deployment/git-server --timeout=180s

./local/seed-git.sh

kubectl apply -f gitops/bootstrap/root-local.yaml

echo
echo "Kind cluster '${CLUSTER_NAME}' is up."
echo "Argo CD is syncing gitops/clusters/local from the in-cluster git server."
echo "external-dns is not part of the local overlay; it needs a DNS account."
echo
echo "Admin password:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
echo
echo
echo "Port-forward the UI with:"
echo "  kubectl -n argocd port-forward svc/argocd-server 8444:443"
echo "Then open https://localhost:8444 (user admin)."
echo
echo "After ingress-nginx is Ready, the sample app is at:"
echo "  http://sample.localtest.me:8080"
echo
echo "Watch applications with:"
echo "  kubectl -n argocd get applications"
