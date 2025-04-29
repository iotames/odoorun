#/bin/sh

. "${RUN_HOME}${DIR_SEPARATOR}conf.sh"
. "${RUN_HOME}${DIR_SEPARATOR}func.sh"

# 检查是否需要重新定义镜像名
if [ -z "${HARBOR_URL:-}" ]; then
    echo "HARBOR_URL未设置，检查默认镜像：$DOCKER_IMAGE_ODOO"
else
    DOCKER_IMAGE_ODOO=$(get_harbor_image "$DOCKER_IMAGE_ODOO")
    echo "检测到HARBOR_URL，检查Harbor镜像：$DOCKER_IMAGE_ODOO"
    if ! image_exists "$DOCKER_IMAGE_ODOO"; then
        login_harbor  # 仅在需要拉取时登录
    fi
fi

# 拉取镜像
if ! image_exists "$DOCKER_IMAGE_ODOO"; then
    # 镜像不存在，执行构建。构建前，可使用docker run -it --rm ubuntu:jammy bash命令进行分步调试。
    # 定义构建目录
    # DOCKER_BUILD_DIR="${ODOO_DEPLOY_HOME}${DIR_SEPARATOR}odoo${DIR_SEPARATOR}17.0"
    # echo "DOCKER_BUILD_DIR=${DOCKER_BUILD_DIR}"
    # docker build --progress=plain --no-cache -t DOCKER_IMAGE_ODOO ${DOCKER_BUILD_DIR}
    # 尝试拉取镜像
    if ! docker pull ${DOCKER_IMAGE_ODOO}; then
        echo "拉取镜像 ${DOCKER_IMAGE_ODOO} 失败，程序退出"
        exit 1
    fi
else
    echo "镜像 ${DOCKER_IMAGE_ODOO} 已存在"
fi

# 检查是否需要克隆仓库
if [ -n "${ODOO_ADDONS_GIT_URL:-}" ] && [ "$ODOO_ADDONS_GIT_URL" != "" ]; then
    # 检查目录是否为空
    if [ -z "$(ls -A "$ODOO_ADDONS")" ]; then
        echo "${ODOO_ADDONS}目录内容为空，开始克隆仓库..."
        # 定义克隆命令
        CLONE_CMD="cd $ODOO_ADDONS && git clone -b ${ODOO_ADDONS_GIT_BRANCH} --single-branch \"$ODOO_ADDONS_GIT_URL\" ."
        echo "执行命令: $CLONE_CMD"
        eval "$CLONE_CMD"
    fi
fi

ODOO_CONFIG_FILE="$ODOO_CONFIG${DIR_SEPARATOR}odoo.conf"
if [ ! -f "$ODOO_CONFIG_FILE" ]; then
    echo "创建配置文件 $ODOO_CONFIG_FILE"
    echo "[options]" > "$ODOO_CONFIG_FILE"
    echo "addons_path = $ODOO_ADDONS_PATH" >> "$ODOO_CONFIG_FILE"
fi

# 检查并创建必要的目录
check_and_mkdir "$ODOO_CONFIG"
check_and_mkdir "$ODOO_ADDONS"
check_and_mkdir "$ODOO_DATA"
check_and_mkdir "$ODOO_LOG"

# 赋予目录所有者权限
chown_odoo_dir "$ODOO_CONFIG"
chown_odoo_dir "$ODOO_ADDONS"
chown_odoo_dir "$ODOO_DATA"
chown_odoo_dir "$ODOO_LOG"
