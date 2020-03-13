#!/bin/bash

DOCKER_CMD_ARG="$1"
ALL_ARGS="$@"

case "$DOCKER_CMD_ARG" in
  "jupyter-lab" | "/opt/conda/bin/jupyter-lab" )
    if [ "${GIT_USERNAME}" != "" ]; then
      git config --global user.name "${GIT_USERNAME}"
    fi
    if [ "${GIT_EMAIL}" != "" ]; then
      git config --global user.email "${GIT_EMAIL}"
    fi
    if [ "${GITHUB_ACCESS_TOKEN}" != "" ]; then
      git config --global credential.helper store
      echo "https://${GITHUB_ACCESS_TOKEN}:@github.com" > ~/.git-credentials
      git config --global url."https://github.com/".insteadOf "ssh://git@github.com/"
      git config --global --add url."https://github.com/".insteadOf "git@github.com:"
      git config --global push.default current
    fi
    exec $ALL_ARGS;;
  "--bash" | "--sh" | "bash" | "sh" | "/bin/bash" | "/bin/sh" )
    bash;;
esac

