#/bin/sh

source "${ODOO_DEPLOY_HOME}${DIR_SEPARATOR}conf.sh"
source "${ODOO_DEPLOY_HOME}${DIR_SEPARATOR}func.sh"

PG_HOME="${ODOO_DEPLOY_HOME}${DIR_SEPARATOR}postgres"
DATA_DIR="$PG_HOME/data"

if [ ! -d $DATA_DIR ]; then
  # 挂载 DATA_DIR 目录时注意是否有写入权限
  echo "mkdir -p $DATA_DIR"
  mkdir -p $DATA_DIR
fi

# 拉取镜像
if [ -z "${HARBOR_URL:-}" ]; then
    echo "HARBOR_URL未设置，检查默认镜像：$DOCKER_IMAGE_DB"
else
    DOCKER_IMAGE_DB="$HARBOR_URL/$DOCKER_IMAGE_DB"
    echo "检测到HARBOR_URL，检查Harbor镜像：$DOCKER_IMAGE_DB"
    if ! image_exists "$DOCKER_IMAGE_DB"; then
        login_harbor  # 仅在需要拉取时登录
    fi
fi

if ! image_exists "$DOCKER_IMAGE_DB"; then
    docker pull ${DOCKER_IMAGE_DB}
else
    echo "镜像 ${DOCKER_IMAGE_DB} 已存在"
fi

# 启动容器
if container_exists "$DOCKER_NAME_DB"; then
    echo "容器 $DOCKER_NAME_DB 已存在"
else
    docker run -d \
      -e POSTGRES_USER=$DB_USER \
      -e POSTGRES_PASSWORD=$DB_PASSWORD \
      -e POSTGRES_DB=$DB_NAME \
      -v $DATA_DIR:/var/lib/postgresql/data \
      -p $DB_PORT:5432 \
      --name $DOCKER_NAME_DB \
      $DOCKER_IMAGE_DB
fi

# --restart always \
# docker run -d -e POSTGRES_USER=odoo -e POSTGRES_PASSWORD=odoo -e POSTGRES_DB=postgres --name db postgres:15
# docker run -d --env-file $ENV_FILE --name db postgres:15