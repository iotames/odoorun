#!/bin/sh

source "${RUN_HOME}${DIR_SEPARATOR}conf.sh"
source "${RUN_HOME}${DIR_SEPARATOR}func.sh"

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

# 重启ODOO容器
docker restart $DOCKER_NAME_ODOO
if [ $? -eq 0 ]; then
    echo "ODOO容器重启成功"
else
    echo "ODOO容器重启失败"
fi
