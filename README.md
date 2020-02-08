# kind-local

When using Tilt with a [Kind](https://github.com/kubernetes-sigs/kind) cluster, 
we recommend using a local registry for faster image pushing and pulling.

This repo documents the best way to set Kind up.

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

## Thanks to

High five to [MicroK8s](https://github.com/ubuntu/microk8s) for the initial local registry feature
that inspired a lot of this work.

The Kind team ran with this, writing up documentation and hooks for how to [set up a local registry](https://kind.sigs.k8s.io/docs/user/local-registry/) with Kind.

This repo modifies the Kind team's script to annotate the nodes with information about the local registry, 
so that Tilt can find it.

## License

Copyright 2019 Windmill Engineering

Licensed under [the Apache License, Version 2.0](LICENSE)
