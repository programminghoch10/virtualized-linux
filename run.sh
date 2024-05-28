#!/bin/bash
set -e
set -x
cd "$(dirname "$0")"

IMAGENAME="virtualized-linux"
CONTAINERNAME="virtualized-linux"

CONTAINER_ARGS=(
    --name "$CONTAINERNAME"
    --publish 3389:3389
    --pull never
    --tty
    --rm
    --interactive
    --shm-size=8G
    --pids-limit -1
    --systemd=true
)

podman container rm --force --volumes "$CONTAINERNAME"

podman build \
    -t $IMAGENAME \
    --layers \
    --arch=$(uname -m) \
    .

podman image ls localhost/$IMAGENAME

podman container run \
    "${CONTAINER_ARGS[@]}" \
    localhost/$IMAGENAME \
    "$@"
