#!/usr/bin/env sh

set -o errexit
set -o nounset

CONTAINER_IMAGE_ID=ferrarimarco/personal-website:latest
TARGET_APP_DIR=/usr/src/app

DOCKER_FLAGS=
if [ -t 0 ]; then
  DOCKER_FLAGS=-it
fi

docker build \
  --build-arg UID="$(id -u)" \
  --build-arg GID="$(id -g)" \
  --network host \
  --tag "${CONTAINER_IMAGE_ID}" .

MODE="${1:-"build"}"
ENVIRONMENT="${2:-"production"}"

docker run ${DOCKER_FLAGS} \
  --rm \
  --volume "$(pwd)":"${TARGET_APP_DIR}" \
  -p "3000:3000" \
  "${CONTAINER_IMAGE_ID}" \
  "${MODE}" -- \
  "${ENVIRONMENT}"
