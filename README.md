# kind-local

When using Tilt with a [Kind](https://github.com/kubernetes-sigs/kind) cluster, 
we recommend using a local registry for faster image pushing and pulling.

This repo documents the best way to set Kind up.

## UPDATE(2023-09-15)

The Kind project maintains an official script for setting up a local registry. The official script
is kept up to date with the latest containerd settings.

https://kind.sigs.k8s.io/docs/user/local-registry/

For a more comprehensive tool for setting up local clusters and registries, check out [ctlptl](http://github.com/tilt-dev/ctlptl).

`ctlptl` uses many of the techniques in the official shell script, but with more features and better error-reporting.

Therefore, this repo is obsolete, but will be archived for posterity.

## Why use Kind with a local registry?

When developing locally, you want to push images to the cluster as fast as possible.

Pushing to an in-cluster image registry skips a lot of overhead:

- Unlike with a remote registry, the image stays local to your machine, with no network traffic

- Unlike with `kind load`, docker will skip pushing any layers that already exist in the registry

This makes it a great solution for iterative local development. But setting it up is awkward and fiddly. This script makes it easy.

## How to Try It

1) Install [Kind](https://github.com/kubernetes-sigs/kind)

2) Copy the [kind-with-registry.sh](kind-with-registry.sh) somewhere on your path.

3) Create a cluster with `kind-with-registry.sh`. Currently it creates the registry at port 5000.

```
kind-with-registry.sh
```

4) Try pushing an image.

```
docker tag alpine localhost:5000/alpine
docker push localhost:5000/alpine
```

You can now use the image name `localhost:5000/alpine` in any resources you deploy to the Kind cluster.

[Tilt](https://tilt.dev) will automatically detect the local registry created by this script,
and do the image tagging dance (as of Tilt v0.12.0).

## How to Use it in CI

We also have instructions for setting Kind up with a local registry in

- [.circleci](.circleci) 

## Thanks to

High five to [MicroK8s](https://github.com/ubuntu/microk8s) for the initial local registry feature
that inspired a lot of this work.

The Kind team ran with this, writing up documentation and hooks for how to [set up a local registry](https://kind.sigs.k8s.io/docs/user/local-registry/) with Kind.

This repo modifies the Kind team's script to apply the local registry configmap, so that tools
like Tilt can discover the local-registry. This protocol is a [Kubernetes Enhancement Proposal](https://github.com/kubernetes/enhancements/issues/1755).

Tested on Kind 0.7.0 and Kind 0.8.0

## License

Copyright 2019 Windmill Engineering

Licensed under [the Apache License, Version 2.0](LICENSE)
