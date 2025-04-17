#!/bin/sh

# 如果存在 .env 文件，从中读取环境变量
if [ -f .env ]; then
    # https://stackoverflow.com/questions/19331497/set-environment-variables-from-file-of-key-value-pairs
    echo "发现.env文件，加载环境变量..."
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

# 获取当前shell脚本所在的目录
RUN_HOME=$(cd "$(dirname "$0")" && pwd)

. "${RUN_HOME}${DIR_SEPARATOR}conf.sh"
. "${RUN_HOME}${DIR_SEPARATOR}func.sh"

# 使用export语法，使得变量可以传递到后续的脚本中
export DIR_SEPARATOR ODOO_DEPLOY_HOME RUN_HOME

# 如果第一个参数是 config 或 conf，则输出所有配置项
if [ "$1" = "config" ] || [ "$1" = "conf" ]; then
    echo "当前配置项:"
    echo "----------------------------------------"
    echo "DIR_SEPARATOR: ${DIR_SEPARATOR}"
    echo "ODOO_DEPLOY_HOME: ${ODOO_DEPLOY_HOME}"
    echo "RUN_HOME: $RUN_HOME"
    show_conf
    exit 0
fi

PG_START_SCRIPT="${RUN_HOME}${DIR_SEPARATOR}postgres${DIR_SEPARATOR}start.sh"
ODOO_START_SCRIPT="${RUN_HOME}${DIR_SEPARATOR}odoo${DIR_SEPARATOR}install.sh"

# 确保脚本有执行权限
chmod +x "${PG_START_SCRIPT}"
chmod +x "${ODOO_START_SCRIPT}"

if [ "$1" = "install" ]; then
    # 检查 ODOO_DEPLOY_HOME 目录是否存在
    if [ ! -d "${ODOO_DEPLOY_HOME}" ]; then
        echo "错误: Odoo 部署目录不存在: ${ODOO_DEPLOY_HOME}"
        exit 1
    fi
    # 启动 Postgres 容器
    sh "${PG_START_SCRIPT}"
    # 启动 Odoo容器
    sh "${ODOO_START_SCRIPT}"
fi

if [ "$1" = "update" ]; then
    ODOO_UPDATE_SCRIPT="${RUN_HOME}${DIR_SEPARATOR}odoo${DIR_SEPARATOR}update.sh"
    sh "${ODOO_UPDATE_SCRIPT}"
fi

if [ "$1" = "docker" ]; then
    DOCKER_ARG="$2"
    if [ "$DOCKER_ARG" = "init" ]; then
        DOCKER_INIT_SCRIPT="${RUN_HOME}${DIR_SEPARATOR}docker${DIR_SEPARATOR}init_etc.sh"
        sh "${DOCKER_INIT_SCRIPT}"
    fi
fi