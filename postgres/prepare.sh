#/bin/sh

# . "${RUN_HOME}${DIR_SEPARATOR}conf.sh"
# conf.sh 里的变量，使用了export导出子Shell使用。已在run.sh中执行过了。这里不需要再导出了。
. "${RUN_HOME}${DIR_SEPARATOR}func.sh"

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

echo "定义容器镜像：DOCKER_IMAGE_DB=$DOCKER_IMAGE_DB"

# 拉取镜像
if ! image_exists "$DOCKER_IMAGE_DB"; then
    if ! docker pull ${DOCKER_IMAGE_DB}; then
        echo "拉取镜像 ${DOCKER_IMAGE_DB} 失败，退出程序"
        exit 1
    fi
else
    echo "镜像 ${DOCKER_IMAGE_DB} 已存在"
fi
