#!/bin/sh

source "${RUN_HOME}${DIR_SEPARATOR}conf.sh"
source "${RUN_HOME}${DIR_SEPARATOR}func.sh"


# 检查并创建必要的目录
check_and_mkdir "$ODOO_DATA"
check_and_mkdir "$ODOO_CONFIG"
check_and_mkdir "$ODOO_ADDONS"

# 拉取镜像
if [ -z "${HARBOR_URL:-}" ]; then
    echo "HARBOR_URL未设置，检查默认镜像：$DOCKER_IMAGE_ODOO"
else
    DOCKER_IMAGE_ODOO="$HARBOR_URL/$DOCKER_IMAGE_ODOO"
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
    docker pull ${DOCKER_IMAGE_ODOO}
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
# -v /home/santic/logs/erp:/var/log/supervisor \
# -v /home/santic/santic_erp_odoo:/mnt/extra-addons \
# -v /home/santic/configs/erp:/mnt/config \
# -v /home/santic/odoo_data/erp:/var/lib/odoo \
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

# db_host = 127.0.0.1
# db_port = 5432
# db_user = odoo
# db_password = root
# db_name = odoo