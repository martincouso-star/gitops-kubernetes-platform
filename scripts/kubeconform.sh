#!/usr/bin/env bash
# Validate rendered manifests against Kubernetes and CRD schemas.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

if [[ ! -d build/manifests ]]; then
  echo "build/manifests is missing. Run scripts/render-manifests.sh first." >&2
  exit 1
fi

kubeconform -summary \
  -ignore-missing-schemas \
  -kubernetes-version "${KUBECONFORM_K8S_VERSION:-1.33.0}" \
  -schema-location default \
  -schema-location 'https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json' \
  -skip CustomResourceDefinition \
  build/manifests
