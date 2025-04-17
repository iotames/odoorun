#/bin/sh

source "${RUN_HOME}${DIR_SEPARATOR}conf.sh"
source "${RUN_HOME}${DIR_SEPARATOR}func.sh"

PG_DATA_DIR="${ODOO_DEPLOY_HOME}${DIR_SEPARATOR}postgres${DIR_SEPARATOR}data"

# 检查并创建必要的目录
check_and_mkdir "$PG_DATA_DIR"

# 拉取镜像
if [ -z "${HARBOR_URL:-}" ]; then
    echo "HARBOR_URL未设置，检查默认镜像：$DOCKER_IMAGE_DB"
else
    DOCKER_IMAGE_DB=$(get_harbor_image "$DOCKER_IMAGE_DB")
    echo "检测到HARBOR_URL，检查Harbor镜像：$DOCKER_IMAGE_DB"
    if ! image_exists "$DOCKER_IMAGE_DB"; then
        login_harbor  # 仅在需要拉取时登录
    fi
fi

if ! image_exists "$DOCKER_IMAGE_DB"; then
    if ! docker pull ${DOCKER_IMAGE_DB}; then
        echo "拉取镜像 ${DOCKER_IMAGE_DB} 失败，退出程序"
        exit 1
    fi
else
    echo "镜像 ${DOCKER_IMAGE_DB} 已存在"
fi

# 启动容器
if container_exists "$DOCKER_NAME_DB"; then
    echo "容器 $DOCKER_NAME_DB 已存在"
else
    # 构建完整的docker run命令
    DOCKER_CMD="docker run -d \
      -e POSTGRES_USER=$DB_USER \
      -e POSTGRES_PASSWORD=$DB_PASSWORD \
      -e POSTGRES_DB=$DB_NAME \
      -v $PG_DATA_DIR:/var/lib/postgresql/data \
      -p $DB_PORT:5432 \
      --name $DOCKER_NAME_DB \
      $DOCKER_IMAGE_DB"
    
    # 打印命令
    echo "执行命令: $DOCKER_CMD"
    
    # 执行命令
    eval "$DOCKER_CMD"
fi

# --restart always \
# docker run -d -e POSTGRES_USER=odoo -e POSTGRES_PASSWORD=odoo -e POSTGRES_DB=postgres --name db postgres:15
# docker run -d --env-file $ENV_FILE --name db postgres:15