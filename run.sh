#!/bin/bash
set -e
set -x
cd "$(dirname "$0")"

IMAGENAME="virtualized-linux"
CONTAINERNAME="virtualized-linux"

CONTAINER_ARGS=(
    --name "$CONTAINERNAME"
    --publish 3389:3389
    --tty
    --rm
    --interactive
    --shm-size=8G
    --pids-limit -1
    --systemd=true
)

[ ! -d share ] && mkdir share
CONTAINER_ARGS+=(--mount type=bind,src="$PWD"/share,dst=/share)

podman container rm --force --volumes "$CONTAINERNAME"

podman build \
    -t $IMAGENAME \
    --pull=newer \
    --layers \
    --arch=$(uname -m) \
    .

podman image inspect localhost/"$IMAGENAME" -f '{{ .Size }} {{ index .RepoTags 0 }}' | numfmt --to=si

exec \
podman container run \
    "${CONTAINER_ARGS[@]}" \
    localhost/$IMAGENAME \
    "$@"
