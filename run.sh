#!/bin/bash
set -e
set -x
cd "$(dirname "$0")"

IMAGENAME="virtualized-linux"
CONTAINERNAME="virtualized-linux"

uid=$(id -u)
subuidsize=$(cat /etc/subuid | grep "^$(id -un):" | cut -d: -f3)

CONTAINER_ARGS=(
    --name "$CONTAINERNAME"
    --hostname "$CONTAINERNAME"
    --publish 3389:3389
    --tty
    --rm
    --interactive
    --shm-size=8G
    --uidmap $uid:0:1
    --uidmap 0:1:$uid
    --uidmap $(($uid + 1)):$(($uid + 1)):$(($subuidsize - $uid))
    --pids-limit -1
    --cap-add=CAP_SYS_ADMIN
    --volume virtualized-linux-home:/home/user
)

[ ! -d share ] && mkdir share
CONTAINER_ARGS+=(--mount type=bind,src="$PWD"/share,dst=/share)

podman container rm \
    --force \
    --volumes \
    "$CONTAINERNAME"

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
