#!/usr/bin/env bash

set -e

echo "==> Running dockerized acceptance testing..."

# Setting docker
DOCKER_NAME=docker
DOCKER_URL="https://download.docker.com/linux/static/stable/x86_64/docker-17.03.2-ce.tgz"
DOCKER_BIN=$(which ${DOCKER_NAME} || echo none)
if [ "${DOCKER_BIN}" == "none" ] ; then
  export DOCKER_BIN=${TESTACC_TEMP_DIR}/${DOCKER_NAME}
  curl -sL ${DOCKER_URL} | tar -xzf - 
  mv docker/docker ${DOCKER_BIN} && rm -rf docker
  chmod 755 ${DOCKER_BIN}
fi

BUILDER_TAG=${BUILDER_TAG:-"terraform-provider-rancher2_builder"}

${DOCKER_BIN} build -t ${BUILDER_TAG} -f $(dirname $0)/Dockerfile.builder .

${DOCKER_BIN} run -i --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $PWD:/go/src/github.com/terraform-providers/terraform-provider-rancher2 \
  ${BUILDER_TAG} make testacc
