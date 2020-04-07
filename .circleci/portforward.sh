#!/bin/bash
#
# Sets up portforwarding for the specified port.
#
# Usage:
#   start-portforward-service.sh
#   portforward.sh [port]
#
# Adapted from
# https://github.com/kubernetes-retired/kubeadm-dind-cluster/blob/master/build/portforward.sh
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

port="${1}"
if [[ "$port" == "" ]]; then
  echo "Must specify a port"
  exit 1
fi

mode=""
localhost="localhost"
if [[ "${IP_MODE:-ipv4}" = "ipv6" ]]; then
  mode="6"
  localhost="[::1]"
fi

socat "TCP-LISTEN:${port},reuseaddr,fork" \
      EXEC:"'docker exec -i portforward socat STDIO TCP${mode}:${localhost}:${port}'" &

# Wait for a successful connection.
for ((n = 0; n < 20; n++)); do
  if socat - "TCP${mode}:localhost:${port}" </dev/null; then
    break
  fi
    sleep 0.5
done
