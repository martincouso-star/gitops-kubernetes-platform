#!/usr/bin/env bash
# Install the tools used by CI. Cluster tools (kind, kubectl) are optional.
set -euo pipefail

BIN="${1:-${HOME}/.local/bin}"
mkdir -p "${BIN}"

install_zip() {
  local url="$1"
  local dest="$2"
  rm -rf /tmp/tool-extract
  mkdir -p /tmp/tool-extract
  curl -fsSL -o /tmp/tool.zip "${url}"
  unzip -o /tmp/tool.zip -d /tmp/tool-extract
  install -m 0755 "/tmp/tool-extract/${dest}" "${BIN}/${dest}"
  rm -rf /tmp/tool-extract /tmp/tool.zip
}

install_tgz_bin() {
  local url="$1"
  local bin="$2"
  curl -fsSL -o /tmp/tool.tgz "${url}"
  tar -C /tmp -xzf /tmp/tool.tgz "${bin}"
  install -m 0755 "/tmp/${bin}" "${BIN}/${bin}"
  rm -f /tmp/tool.tgz "/tmp/${bin}"
}

echo "Installing Terraform, tflint, helm, kustomize, kubeconform, conftest into ${BIN}"

install_zip "https://releases.hashicorp.com/terraform/1.17.1/terraform_1.17.1_linux_amd64.zip" terraform
install_zip "https://github.com/terraform-linters/tflint/releases/download/v0.66.0/tflint_linux_amd64.zip" tflint
install_tgz_bin "https://github.com/yannh/kubeconform/releases/download/v0.8.0/kubeconform-linux-amd64.tar.gz" kubeconform
install_tgz_bin "https://github.com/open-policy-agent/conftest/releases/download/v0.71.1/conftest_0.71.1_Linux_x86_64.tar.gz" conftest
install_tgz_bin "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v5.8.3/kustomize_v5.8.3_linux_amd64.tar.gz" kustomize

curl -fsSL -o /tmp/helm.tgz "https://get.helm.sh/helm-v3.22.1-linux-amd64.tar.gz"
tar -C /tmp -xzf /tmp/helm.tgz
install -m 0755 /tmp/linux-amd64/helm "${BIN}/helm"
rm -rf /tmp/linux-amd64 /tmp/helm.tgz

deps="$(dirname "${BIN}")/checkov-deps"
python3 -m pip install --disable-pip-version-check --target "${deps}" "checkov==3.2.495"
cat > "${BIN}/checkov" << EOF
#!/usr/bin/env python3
import sys
sys.path.insert(0, "${deps}")
from checkov.main import Checkov
raise SystemExit(Checkov().run())
EOF
chmod 0755 "${BIN}/checkov"

if [[ "${INSTALL_CLUSTER_TOOLS:-0}" == "1" ]]; then
  curl -fsSL -o "${BIN}/kubectl" "https://dl.k8s.io/release/v1.37.2/bin/linux/amd64/kubectl"
  chmod +x "${BIN}/kubectl"
  curl -fsSL -o /tmp/kind "https://kind.sigs.k8s.io/dl/v0.33.0/kind-linux-amd64"
  install -m 0755 /tmp/kind "${BIN}/kind"
fi

echo "Tools installed. Ensure ${BIN} is on PATH."
