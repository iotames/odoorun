#!/bin/sh

. "${RUN_HOME}${DIR_SEPARATOR}func.sh"

# 检查docker是否已安装
check_docker_installed

DOCKER_ETC_DIR="/etc/docker"
DOCKER_ETC_FILE="$DOCKER_ETC_DIR/daemon.json"
COPY_FROM_FILE="${RUN_HOME}${DIR_SEPARATOR}docker${DIR_SEPARATOR}etc${DIR_SEPARATOR}dockerdaemon.json"

if [ ! -d $DOCKER_ETC_DIR ]; then
  echo "mkdir -p $DOCKER_ETC_DIR"
  mkdir -p $DOCKER_ETC_DIR
fi

if [ ! -f $DOCKER_ETC_FILE ]; then
    COPY_CMD="cp $COPY_FROM_FILE $DOCKER_ETC_FILE"
    echo "执行命令: $COPY_CMD"
    eval "$COPY_CMD"
    cat $DOCKER_ETC_FILE
fi

restart_docker