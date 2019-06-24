# kind-local

This is a Proof of Concept of how to run a local container registry in [Kind](https://github.com/kubernetes-sigs/kind) (Kubernetes in Docker).

## Why

When developing locally, you want to push images to the cluster as fast as possible.

Pushing to an in-cluster container registry skips a lot of overhead:

- Unlike with a remote registry, the image stays local to your machine, with no network traffic

- Unlike with `kind load`, docker will skip pushing any layers that already exist in the registry

This makes it a great solution for iterative local development. But setting it up is awkward and fiddly.

This repo demonstrates how you might build a more robust solution.

## How to Try It

1) Create a cluster

```
kind create cluster
```

2) Start the registry. Currently it creates the registry at port 32001

```
./kind-registry.sh
```

3) Try pushing an image.

```
docker tag alpine localhost:32001/alpine
docker push localhost:32001/alpine
```

You can now use the image name `localhost:32001/alpine` in any resources you deploy to the Kind cluster

## How it Works

`kind-registry.sh` has three major jobs:

1) Deploy a container registry in the cluster that's available on each node at 32001.

Currently we do this with [registry.yaml](registry.yaml).

This runs a single pod and exposes it with a NodePort, which means
it only works if your Kind cluster is a single-node cluster.

TODO: make this work with a multi-node cluster.

2) Configure containerd to trust the registry at 32001, even though it's on http (instead of https).

This is trickier. See [config.toml](config.toml), which configures this as
`[plugins.cri.registry.mirrors."local.insecure-registry.io"]`.

3) Expose the registry as 32001 on the host.

We do this with `kubectl port-forward`. A more robust implementation would have
to manage the port-forwarding.

## Thanks to

Inspired by [MicroK8s](https://github.com/ubuntu/microk8s)'s private registry feature.

Much of the code in this repo is inspired by the equivalent registry setup in MicroK8s.

The KIND
[private registries doc](https://github.com/kubernetes-sigs/kind/blob/master/site/content/docs/user/private-registries.md)
had some helpful sample code in how to set up registry configuration.

We're hoping that all local Kubernetes tooling will eventually support this workflow natively.
See [this issue](https://github.com/kubernetes-sigs/kind/issues/602) in the Kind repo for more technical discussion.

## License

Copyright 2019 Windmill Engineering

Licensed under [the Apache License, Version 2.0](LICENSE)
