#!/usr/bin/env bats
#
# Copyright (c) 2019 Intel Corporation
#
# SPDX-License-Identifier: Apache-2.0
#

load "${BATS_TEST_DIRNAME}/../../.ci/lib.sh"
load "${BATS_TEST_DIRNAME}/../../lib/common.bash"
issue="https://github.com/kata-containers/runtime/issues/2186"

setup() {
	skip "test not working see: ${issue}"
	export KUBECONFIG="$HOME/.kube/config"
	pod_name="cpu-test"
	container_name="c1"
	get_pod_config_dir
}

@test "Check number of cpus" {
	skip "test not working see: ${issue}"
	# Create pod
	kubectl create -f "${pod_config_dir}/pod-number-cpu.yaml"

	# Check pod creation
	kubectl wait --for=condition=Ready pod "$pod_name"

	retries="10"
	max_number_cpus="3"

	for _ in $(seq 1 "$retries"); do
		# Get number of cpus
		number_cpus=$(kubectl exec -ti pod/"$pod_name" -c "$container_name" nproc | sed 's/[[:space:]]//g')
		# Verify number of cpus
		[ "$number_cpus" -le "$max_number_cpus" ]
		sleep 1
	done
}

teardown() {
	skip "test not working see: ${issue}"
	kubectl delete pod "$pod_name"
}
