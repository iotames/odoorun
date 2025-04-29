#!/bin/sh

# 在当前Shell环境中执行prepare.sh脚本文件，而非启动子Shell
# 因此，prepare.sh脚本的变量，不需要export，就能在当前Shell中使用。
# 要让其他Shell也能使用这些变量，则需要使用export命令将它们导出。
. "${RUN_HOME}${DIR_SEPARATOR}odoo${DIR_SEPARATOR}prepare.sh"

# 启动容器
if container_exists "$DOCKER_NAME_ODOO"; then
    echo "容器 $DOCKER_NAME_ODOO 已存在。请使用update命令更新容器。"
else
    # 构建完整的docker run命令
    DOCKER_CMD="docker run -d --restart=always \
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
    update_requirements
fi
