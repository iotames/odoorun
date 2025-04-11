#!/bin/sh

DOCKER_ETC_DIR="/etc/docker"
DOCKER_ETC_FILE="$DOCKER_ETC_DIR/daemon.json"
DOCKER_HOME_DIR="$HOME/docker"

if [ ! -d $DOCKER_ETC_DIR ]; then
  echo "mkdir -p $DOCKER_ETC_DIR"
  mkdir -p $DOCKER_ETC_DIR
fi

if [ ! -f $DOCKER_ETC_FILE ]; then
  echo "$DOCKER_HOME_DIR/etc/dockerdaemon.json > $DOCKER_ETC_FILE"
  cat "$DOCKER_HOME_DIR/etc/dockerdaemon.json" > $DOCKER_ETC_FILE
  cat $DOCKER_ETC_FILE
fi
