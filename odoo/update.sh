#!/bin/sh

. "${RUN_HOME}${DIR_SEPARATOR}conf.sh"
. "${RUN_HOME}${DIR_SEPARATOR}func.sh"

# 更新代码仓库
if [ -n "${ODOO_ADDONS_GIT_URL:-}" ] && [ "$ODOO_ADDONS_GIT_URL" != "" ]; then
    # 检查是否存在.git目录
    if [ -d "${ODOO_ADDONS}/.git" ]; then
        echo "检测到${ODOO_ADDONS}目录下存在.git，执行git pull操作..."
        # git config --global --add safe.directory ${ODOO_ADDONS}
        # 定义git pull命令
        PULL_CMD="cd \"$ODOO_ADDONS\" && git pull"
        echo "执行命令: $PULL_CMD"
        eval "$PULL_CMD"
    else
        echo "${ODOO_ADDONS}目录下不存在.git目录，跳过git pull操作"
    fi
fi

ODOO_CONFIG_FILE="$ODOO_CONFIG${DIR_SEPARATOR}odoo.conf"

# 检查配置文件是否存在
if [ -f "$ODOO_CONFIG_FILE" ]; then
    # 读取并打印配置文件中的键值对
    echo "正在读取配置文件: $ODOO_CONFIG_FILE"
    # 一次性读取配置文件内容
    CONFIG_CONTENT=$(cat "$ODOO_CONFIG_FILE")
    # 调用函数添加配置项
    add_config_if_missing "data_dir" "/var/lib/odoo" "$ODOO_CONFIG_FILE"
    add_config_if_missing "logfile" "/var/log/odoo/odoo.log" "$ODOO_CONFIG_FILE"
else
    echo "配置文件不存在: $ODOO_CONFIG_FILE"
fi

# 进入$DOCKER_NAME_ODOO容器执行命令
docker exec -it $DOCKER_NAME_ODOO /bin/bash -c "if [ -f /mnt/extra-addons/requirements.txt ]; then \
    echo '检测到requirements.txt文件，开始安装依赖...' && \
    pip install -r /mnt/extra-addons/requirements.txt -i https://mirrors.aliyun.com/pypi/simple/; \
else \
    echo 'requirements.txt文件不存在，跳过依赖安装'; \
fi"

# 重启ODOO容器
docker restart $DOCKER_NAME_ODOO
if [ $? -eq 0 ]; then
    echo "ODOO容器重启成功"
else
    echo "ODOO容器重启失败"
fi
