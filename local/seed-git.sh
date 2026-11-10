#!/usr/bin/env bash
# Push the current HEAD to the in-cluster git daemon used by the local Argo CD.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

GIT_LOCAL_PORT="${GIT_LOCAL_PORT:-19418}"
CLUSTER_NAME="${CLUSTER_NAME:-gitops-platform}"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Run this from a git checkout." >&2
  exit 1
fi

if ! git rev-parse HEAD >/dev/null 2>&1; then
  echo "There is no commit to push." >&2
  exit 1
fi

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Working tree has uncommitted changes. The in-cluster repo only receives committed files."
fi

kubectl --context "kind-${CLUSTER_NAME}" -n git-server rollout status deployment/git-server --timeout=180s

kubectl --context "kind-${CLUSTER_NAME}" -n git-server port-forward "svc/git-server" "${GIT_LOCAL_PORT}:9418" >/tmp/gitops-port-forward.log 2>&1 &
pf_pid=$!
cleanup() {
  kill "${pf_pid}" >/dev/null 2>&1 || true
}
trap cleanup EXIT

for _ in $(seq 1 30); do
  if git ls-remote "git://127.0.0.1:${GIT_LOCAL_PORT}/platform.git" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

git push --force "git://127.0.0.1:${GIT_LOCAL_PORT}/platform.git" "HEAD:refs/heads/main"

if kubectl --context "kind-${CLUSTER_NAME}" -n argocd get applications >/dev/null 2>&1; then
  kubectl --context "kind-${CLUSTER_NAME}" -n argocd get applications -o name \
    | xargs -r kubectl --context "kind-${CLUSTER_NAME}" -n argocd annotate --overwrite argocd.argoproj.io/refresh=hard
fi

echo "Pushed HEAD to the local git server as main."
