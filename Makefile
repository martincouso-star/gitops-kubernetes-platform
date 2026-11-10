.PHONY: fmt validate tflint checkov render kubeconform conftest ci local-up local-down local-sync

TF_DIRS := terraform/environments/dev terraform/environments/prod terraform/environments/gke terraform/bootstrap/remote-state

fmt:
	terraform fmt -check -recursive terraform

validate:
	@set -e; \
	for dir in $(TF_DIRS); do \
	  echo "== $$dir"; \
	  terraform -chdir=$$dir init -backend=false -input=false; \
	  terraform -chdir=$$dir validate; \
	done

tflint:
	tflint --init
	tflint --recursive

checkov:
	checkov -d terraform --config-file .checkov.yaml --compact

render:
	./scripts/render-manifests.sh

kubeconform: render
	./scripts/kubeconform.sh

conftest: render
	conftest verify --policy policy
	conftest test --policy policy build/manifests/sample-app-local.yaml build/manifests/sample-app-dev.yaml build/manifests/sample-app-prod.yaml

ci: fmt validate tflint checkov render
	./scripts/kubeconform.sh
	conftest verify --policy policy
	conftest test --policy policy build/manifests/sample-app-local.yaml build/manifests/sample-app-dev.yaml build/manifests/sample-app-prod.yaml

local-up:
	./local/bootstrap.sh

local-down:
	kind delete cluster --name gitops-platform

local-sync:
	./local/seed-git.sh
