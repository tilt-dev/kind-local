# Kind on CircleCI with Remote Docker

This config demonstrates how to run Kind 
with a local registry on CircleCI.

## Why is it hard to run Kind on CircleCI?

CircleCI doesn't run Docker the same way you run Docker on your
local computer. 

Instead, CircleCI creates a [remote environment](https://circleci.com/docs/2.0/building-docker-images/)
and runs Docker there.

This means that when you run Kind, you need to make sure
that whenever you want to talk to the Kind cluster,
you're talking to the remote docker, not to localhost.

## How do I use it?

Create a circleci job that looks like this:

```
version: 2.1
jobs:
  build:
    docker:
      - image: tiltdev/circleci-kind:v1.4.0

    steps:
      - setup_remote_docker
      - checkout
      - run: with-kind-cluster.sh [YOUR TEST COMMAND]
```

The `circleci-kind` image has all the tools you need to set up
and talk to the cluster. You can build on this image with:

```
FROM tiltdev/circleci-kind:v1.4.0
```

Or copy out the helper scripts:

```
COPY --from=tiltdev/circleci-kind:v1.4.0 /usr/local/bin/start-portforward-service.sh /usr/local/bin/
COPY --from=tiltdev/circleci-kind:v1.4.0 /usr/local/bin/portforward.sh /usr/local/bin/
COPY --from=tiltdev/circleci-kind:v1.4.0 /usr/local/bin/with-kind-cluster.sh /usr/local/bin/
```

See [Dockerfile](Dockerfile) for instructions on how to add these tools to
your own docker image.

## How does it work?

There are five steps

1) Create a port-forward service on the remote machine
   that knows how to forward connections.
   
2) Create an image registry.

3) Create a Kind cluster connected to the image registry.

4) Tell the port-forward service to connect the image registry to localhost.

5) Tell the port-forward service to connect the Kind cluster to localhost.
