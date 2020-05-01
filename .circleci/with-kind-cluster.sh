#!/bin/bash
#
# Starts a Kind cluster and runs a command against it.
#
# Usage:
#   with-kind-cluster.sh kubectl cluster-info
#
# Adapted from:
# https://github.com/kubernetes-sigs/kind/commits/master/site/static/examples/kind-with-registry.sh
#
# Copyright 2020 The Kubernetes Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -oe errexit

# desired cluster name; default is "kind"
KIND_CLUSTER_NAME="kind"

# default registry name and port
reg_name='kind-registry'
reg_port='5000'

echo "> initializing Docker registry"

# create registry container unless it already exists
running="$(docker inspect -f '{{.State.Running}}' "${reg_name}" 2>/dev/null || true)"
if [ "${running}" != 'true' ]; then
  docker run \
    -d --restart=always -p "${reg_port}:5000" --name "${reg_name}" \
    registry:2
fi

echo "> initializing Kind cluster: ${KIND_CLUSTER_NAME} with registry ${reg_name}"

# create a cluster with the local registry enabled in containerd
cat <<EOF | kind create cluster --name "${KIND_CLUSTER_NAME}" --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:${reg_port}"]
    endpoint = ["http://${reg_name}:${reg_port}"]
EOF

docker network connect kind "${reg_name}"

echo "> port-forwarding k8s API server"
/usr/local/bin/start-portforward-service.sh start

APISERVER_PORT=$(kubectl config view -o jsonpath='{.clusters[].cluster.server}' | cut -d: -f 3 -)
/usr/local/bin/portforward.sh $APISERVER_PORT
kubectl get nodes # make sure it worked

echo "> port-forwarding local registry"
/usr/local/bin/portforward.sh $reg_port

echo "> annotating nodes"

# and annotate each node with registry info (for Tilt to detect)
for node in $(kind get nodes --name "${KIND_CLUSTER_NAME}"); do
  kubectl annotate node "${node}" tilt.dev/registry=localhost:${reg_port};
done

echo "> waiting for kubernetes node(s) become ready"
kubectl wait --for=condition=ready node --all --timeout=60s

echo "> with-kind-cluster.sh setup complete! Running user script: $@"
exec "$@"
