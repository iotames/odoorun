#!/bin/sh

# 在当前Shell环境中执行prepare.sh脚本文件，而非启动子Shell
# 因此，prepare.sh脚本的变量，不需要export，就能在当前Shell中使用。
# 要让其他Shell也能使用这些变量，则需要使用export命令将它们导出。
. "${RUN_HOME}${DIR_SEPARATOR}odoo${DIR_SEPARATOR}prepare.sh"

# 更新代码仓库
if [ -n "${ODOO_ADDONS_GIT_URL:-}" ] && [ "$ODOO_ADDONS_GIT_URL" != "" ]; then
    # 检查是否存在.git目录
    if [ -d "${ODOO_ADDONS}/.git" ]; then
        echo "检测到${ODOO_ADDONS}目录存在.git，执行git fetch操作..."
        # git config --global --add safe.directory ${ODOO_ADDONS}
        # 定义git fetch命令
        PULL_CMD="cd \"$ODOO_ADDONS\" && git fetch origin ${ODOO_ADDONS_GIT_BRANCH} && git merge origin/${ODOO_ADDONS_GIT_BRANCH} && git switch ${ODOO_ADDONS_GIT_BRANCH}"
        echo "执行命令: $PULL_CMD"
        eval "$PULL_CMD"
    else
        echo "${ODOO_ADDONS}目录下不存在.git目录，跳过git fetch操作"
    fi
fi


# 检查配置文件是否存在
if [ -f "$ODOO_CONFIG_FILE" ]; then
    # 读取并打印配置文件中的键值对
    echo "正在读取配置文件: $ODOO_CONFIG_FILE"
    # 一次性读取配置文件内容
    # CONFIG_CONTENT=$(cat "$ODOO_CONFIG_FILE")
    # 调用函数添加配置项
    add_config_if_missing "data_dir" "/var/lib/odoo" "$ODOO_CONFIG_FILE"
    add_config_if_missing "logfile" "/var/log/odoo/odoo.log" "$ODOO_CONFIG_FILE"
else
    echo "配置文件不存在: $ODOO_CONFIG_FILE"
    exit 1
fi

# 更新requirements.txt模块依赖
update_requirements

# 更新模块
UPDATE_CMD="docker exec $DOCKER_NAME_ODOO odoo -u $ODOO_UPDATE_MODULES --stop-after-init"
echo "执行命令: $UPDATE_CMD"
eval "$UPDATE_CMD"

# 重启ODOO容器
docker restart $DOCKER_NAME_ODOO
if [ $? -eq 0 ]; then
    echo "ODOO容器重启成功"
else
    echo "ODOO容器重启失败"
fi
