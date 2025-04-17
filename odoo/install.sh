#!/bin/sh

. "${RUN_HOME}${DIR_SEPARATOR}conf.sh"
. "${RUN_HOME}${DIR_SEPARATOR}func.sh"

# 检查并创建必要的目录
check_and_mkdir "$ODOO_CONFIG"
check_and_mkdir "$ODOO_ADDONS"
check_and_mkdir "$ODOO_DATA"
check_and_mkdir "$ODOO_LOG"

# 检查是否需要克隆仓库
if [ -n "${ODOO_ADDONS_GIT_URL:-}" ] && [ "$ODOO_ADDONS_GIT_URL" != "" ]; then
    # 检查目录是否为空
    if [ -z "$(ls -A "$ODOO_ADDONS")" ]; then
        echo "${ODOO_ADDONS}目录内容为空，开始克隆仓库..."
        # 定义克隆命令
        CLONE_CMD="cd \"$ODOO_ADDONS\" && git clone \"$ODOO_ADDONS_GIT_URL\" ."
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

chown_odoo_dir "$ODOO_CONFIG"
chown_odoo_dir "$ODOO_ADDONS"
chown_odoo_dir "$ODOO_DATA"
chown_odoo_dir "$ODOO_LOG"

# 拉取镜像
if [ -z "${HARBOR_URL:-}" ]; then
    echo "HARBOR_URL未设置，检查默认镜像：$DOCKER_IMAGE_ODOO"
else
    DOCKER_IMAGE_ODOO=$(get_harbor_image "$DOCKER_IMAGE_ODOO")
    echo "检测到HARBOR_URL，检查Harbor镜像：$DOCKER_IMAGE_ODOO"
    if ! image_exists "$DOCKER_IMAGE_ODOO"; then
        login_harbor  # 仅在需要拉取时登录
    fi
fi

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

# 启动容器
if container_exists "$DOCKER_NAME_ODOO"; then
    echo "容器 $DOCKER_NAME_ODOO 已存在"
else
    # 构建完整的docker run命令
    DOCKER_CMD="docker run -d \
      -p $ODOO_WEB_PORT:8069 \
      -v $ODOO_DATA:/var/lib/odoo \
      -v $ODOO_CONFIG:/etc/odoo \
      -v $ODOO_ADDONS:/mnt/extra-addons \
      -v $ODOO_LOG:/var/log/odoo \
      --link $DOCKER_NAME_DB:db \
      --name $DOCKER_NAME_ODOO \
      $DOCKER_IMAGE_ODOO"
    
    # 打印命令
    echo "执行命令: $DOCKER_CMD"
    
    # 执行命令
    eval "$DOCKER_CMD"
fi

# -e INSTALL_MODULES=base
# "-- -i base" 整个命令参数，放在Docker命令的末尾
# --restart always
#   -v $ODOO_ADDONS:/mnt/extra-addons
#   -v $ODOO_CONFIG:/mnt/config

# docker run -d --name=santic_erp --restart=always \
# -v /home/santic/odoo17.0:/odoo \
# -p 8080:8069 \
# --link db_16.0:db \
# -t odoo17 /usr/bin/supervisord

# --network=bridge 默认使用桥接网络
# --runtime=runc 默认使用runc作为容器运行时
# -t odoo17 /usr/bin/supervisord 指定容器的镜像和启动命令

# https://hub.docker.com/_/odoo
# docker run -v odoo-data:/var/lib/odoo -d -p 8069:8069 --name odoo --link db:db -t odoo
# docker run -d -v odoo-db:/var/lib/postgresql/data -e POSTGRES_USER=odoo -e POSTGRES_PASSWORD=odoo -e POSTGRES_DB=postgres --name db postgres:15

# [options]
# addons_path = /mnt/extra-addons,/mnt/extra-addons/santic/busyness,/mnt/extra-addons/santic/common,/mnt/extra-addons/santic/tech,/mnt/extra-addons/third_party/common,/mnt/extra-addons/third_party/tech,/mnt/extra-addons/third_party/busyness
# data_dir = /var/lib/odoo
# logfile = /var/log/odoo/odoo.log
# db_host = db
# db_maxconn = 1000
# db_name = xxx
# db_filer = xxx
# db_password = odoo
# db_user = odoo
# without_demo = True
