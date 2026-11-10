package main_test

import rego.v1

import data.main

good_deployment := {
	"apiVersion": "apps/v1",
	"kind": "Deployment",
	"metadata": {
		"name": "sample-app",
		"labels": {"app.kubernetes.io/name": "sample-app"},
	},
	"spec": {"template": {"spec": {
		"securityContext": {"runAsNonRoot": true},
		"containers": [{
			"name": "nginx",
			"image": "nginxinc/nginx-unprivileged:1.27.4-alpine",
			"resources": {
				"requests": {"cpu": "25m", "memory": "32Mi"},
				"limits": {"cpu": "200m", "memory": "128Mi"},
			},
			"readinessProbe": {"httpGet": {"path": "/", "port": 8080}},
			"livenessProbe": {"httpGet": {"path": "/", "port": 8080}},
			"securityContext": {
				"allowPrivilegeEscalation": false,
				"capabilities": {"drop": ["ALL"]},
			},
		}],
	}}},
}

test_allows_a_hardened_deployment if {
	count(main.deny) == 0 with input as good_deployment
}

test_rejects_latest_tag if {
	bad := json.patch(good_deployment, [{
		"op": "replace",
		"path": "/spec/template/spec/containers/0/image",
		"value": "nginx:latest",
	}])
	count(main.deny) > 0 with input as bad
}

test_rejects_privileged if {
	bad := json.patch(good_deployment, [{
		"op": "add",
		"path": "/spec/template/spec/containers/0/securityContext/privileged",
		"value": true,
	}])
	count(main.deny) > 0 with input as bad
}

test_rejects_missing_label if {
	bad := json.remove(good_deployment, ["/metadata/labels"])
	count(main.deny) > 0 with input as bad
}

test_ignores_unrelated_kinds if {
	count(main.deny) == 0 with input as {"kind": "ConfigMap", "metadata": {"name": "cfg"}}
}
