#!/bin/sh

# 定义镜像标签
ODOO_IMAGE_TAG="17.0-20250401"
# 定义构建目录
DOCKER_BUILD_DIR="${ODOO_DEPLOY_HOME}${DIR_SEPARATOR}odoo${DIR_SEPARATOR}17.0"

echo "DOCKER_BUILD_DIR=${DOCKER_BUILD_DIR}"
echo "ODOO_IMAGE_TAG=${ODOO_IMAGE_TAG}"

# 检查镜像是否存在
if ! docker images odoo:${ODOO_IMAGE_TAG} | grep -q "${ODOO_IMAGE_TAG}"; then
    # 镜像不存在，执行构建
    docker build -t odoo:${ODOO_IMAGE_TAG} ${DOCKER_BUILD_DIR}
fi

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
# docker run -d -e POSTGRES_USER=odoo -e POSTGRES_PASSWORD=odoo -e POSTGRES_DB=postgres --name db postgres:15
# docker run -v odoo-data:/var/lib/odoo -d -p 8069:8069 --name odoo --link db:db -t odoo
# docker run -d -v odoo-db:/var/lib/postgresql/data -e POSTGRES_USER=odoo -e POSTGRES_PASSWORD=odoo -e POSTGRES_DB=postgres --name db postgres:15


