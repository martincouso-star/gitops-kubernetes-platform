package main

import rego.v1

workload_kinds := {"Deployment", "StatefulSet", "DaemonSet", "Pod"}

is_workload if {
	input.kind in workload_kinds
}

pod_spec := input.spec.template.spec if {
	input.kind in {"Deployment", "StatefulSet", "DaemonSet"}
}

pod_spec := input.spec if {
	input.kind == "Pod"
}

deny contains msg if {
	is_workload
	not input.metadata.labels["app.kubernetes.io/name"]
	msg := sprintf("%s/%s is missing label app.kubernetes.io/name", [input.kind, object_name])
}

deny contains msg if {
	is_workload
	container := pod_spec.containers[_]
	not container.resources.requests.cpu
	msg := sprintf("%s/%s container %s is missing cpu requests", [input.kind, object_name, container.name])
}

deny contains msg if {
	is_workload
	container := pod_spec.containers[_]
	not container.resources.requests.memory
	msg := sprintf("%s/%s container %s is missing memory requests", [input.kind, object_name, container.name])
}

deny contains msg if {
	is_workload
	container := pod_spec.containers[_]
	not container.resources.limits.cpu
	msg := sprintf("%s/%s container %s is missing cpu limits", [input.kind, object_name, container.name])
}

deny contains msg if {
	is_workload
	container := pod_spec.containers[_]
	not container.resources.limits.memory
	msg := sprintf("%s/%s container %s is missing memory limits", [input.kind, object_name, container.name])
}

deny contains msg if {
	is_workload
	input.kind != "Pod"
	container := pod_spec.containers[_]
	not container.readinessProbe
	msg := sprintf("%s/%s container %s is missing a readinessProbe", [input.kind, object_name, container.name])
}

deny contains msg if {
	is_workload
	input.kind != "Pod"
	container := pod_spec.containers[_]
	not container.livenessProbe
	msg := sprintf("%s/%s container %s is missing a livenessProbe", [input.kind, object_name, container.name])
}

deny contains msg if {
	is_workload
	container := pod_spec.containers[_]
	endswith(container.image, ":latest")
	msg := sprintf("%s/%s container %s uses the latest tag", [input.kind, object_name, container.name])
}

deny contains msg if {
	is_workload
	container := pod_spec.containers[_]
	not contains(container.image, ":")
	msg := sprintf("%s/%s container %s has no image tag", [input.kind, object_name, container.name])
}

deny contains msg if {
	is_workload
	container := pod_spec.containers[_]
	container.securityContext.privileged == true
	msg := sprintf("%s/%s container %s is privileged", [input.kind, object_name, container.name])
}

deny contains msg if {
	is_workload
	container := pod_spec.containers[_]
	container.securityContext.allowPrivilegeEscalation != false
	msg := sprintf("%s/%s container %s must set allowPrivilegeEscalation=false", [input.kind, object_name, container.name])
}

deny contains msg if {
	is_workload
	container := pod_spec.containers[_]
	not "ALL" in container.securityContext.capabilities.drop
	msg := sprintf("%s/%s container %s must drop all capabilities", [input.kind, object_name, container.name])
}

deny contains msg if {
	is_workload
	pod_spec.hostNetwork == true
	msg := sprintf("%s/%s must not set hostNetwork", [input.kind, object_name])
}

deny contains msg if {
	is_workload
	pod_spec.hostPID == true
	msg := sprintf("%s/%s must not set hostPID", [input.kind, object_name])
}

deny contains msg if {
	is_workload
	pod_spec.hostIPC == true
	msg := sprintf("%s/%s must not set hostIPC", [input.kind, object_name])
}

deny contains msg if {
	is_workload
	pod_spec.securityContext.runAsNonRoot != true
	not container_runs_as_non_root
	msg := sprintf("%s/%s must set runAsNonRoot", [input.kind, object_name])
}

container_runs_as_non_root if {
	container := pod_spec.containers[_]
	container.securityContext.runAsNonRoot == true
}

object_name := name if {
	name := input.metadata.name
}

object_name := "unnamed" if {
	not input.metadata.name
}
