#!/bin/sh

# 如果存在 .env 文件，从中读取环境变量
if [ -f .env ]; then
    # https://stackoverflow.com/questions/19331497/set-environment-variables-from-file-of-key-value-pairs
    export $(cat .env | sed 's/#.*//g' | xargs)
fi

# 获取目录分隔符：如果不存在 DIR_SEPARATOR 环境变量，设置为 '/'
if [ -z "${DIR_SEPARATOR}" ]; then
    DIR_SEPARATOR='/'
fi

# 获取 Odoo 部署目录：如果不存在 ODOO_DEPLOY_HOME 环境变量，设置为当前项目根目录
if [ -z "${ODOO_DEPLOY_HOME}" ]; then
    ODOO_DEPLOY_HOME=$(pwd)
fi

echo "DIR_SEPARATOR=${DIR_SEPARATOR}"
echo "ODOO_DEPLOY_HOME=${ODOO_DEPLOY_HOME}"

# 检查 Odoo 启动脚本是否存在
ODOO_START_SCRIPT="${ODOO_DEPLOY_HOME}${DIR_SEPARATOR}odoo${DIR_SEPARATOR}start.sh"
if [ ! -f "${ODOO_START_SCRIPT}" ]; then
    echo "错误: Odoo 启动脚本不存在: ${ODOO_START_SCRIPT}"
    exit 1
fi

# 确保脚本有执行权限
chmod +x "${ODOO_START_SCRIPT}"

# 使用export语法，使得变量可以传递到后续的脚本中
export DIR_SEPARATOR
export ODOO_DEPLOY_HOME

# 启动 Odoo容器
sh "${ODOO_START_SCRIPT}"
