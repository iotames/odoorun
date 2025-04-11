#/bin/sh

BOX_HOME="$HOME/docker/postgres"

ENV_FILE="$BOX_HOME/conf/.env"
DATA_DIR="$BOX_HOME/data"

if [ ! -d $DATA_DIR ]; then
  # 挂载 DATA_DIR 目录时注意是否有写入权限
  echo "mkdir -p $DATA_DIR"
  mkdir -p $DATA_DIR
fi

if [ ! -f ENV_FILE ]; then
  cp "$BOX_HOME/conf/env.sample" $ENV_FILE
fi

docker run -d --restart always --name postgres \
  --env-file $ENV_FILE \
  -v $DATA_DIR:/var/lib/postgresql/data \
  -p 5432:5432 \
  postgres:17.4-bookworm
