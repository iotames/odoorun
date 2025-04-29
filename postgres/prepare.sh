#/bin/sh

. "${RUN_HOME}${DIR_SEPARATOR}conf.sh"
. "${RUN_HOME}${DIR_SEPARATOR}func.sh"

PG_DATA_DIR="${ODOO_DEPLOY_HOME}${DIR_SEPARATOR}postgres${DIR_SEPARATOR}data"

# 检查并创建必要的目录
check_and_mkdir "$PG_DATA_DIR"

# 检查是否需要重新定义镜像名
if [ -z "${HARBOR_URL:-}" ]; then
    echo "HARBOR_URL未设置，检查默认镜像：$DOCKER_IMAGE_DB"
else
    DOCKER_IMAGE_DB=$(get_harbor_image "$DOCKER_IMAGE_DB")
    echo "检测到HARBOR_URL，检查Harbor镜像：$DOCKER_IMAGE_DB"
    if ! image_exists "$DOCKER_IMAGE_DB"; then
        login_harbor  # 仅在需要拉取时登录
    fi
fi

# 拉取镜像
if ! image_exists "$DOCKER_IMAGE_DB"; then
    if ! docker pull ${DOCKER_IMAGE_DB}; then
        echo "拉取镜像 ${DOCKER_IMAGE_DB} 失败，退出程序"
        exit 1
    fi
else
    echo "镜像 ${DOCKER_IMAGE_DB} 已存在"
fi
