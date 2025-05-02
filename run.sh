#!/bin/sh

# 获取目录分隔符：如果不存在 DIR_SEPARATOR 环境变量，设置为 '/'
if [ -z "${DIR_SEPARATOR}" ]; then
    DIR_SEPARATOR='/'
fi

# 获取当前shell脚本所在的目录
if [ -z "${RUN_HOME}" ]; then
    RUN_HOME=$(cd "$(dirname "$0")" && pwd)
fi

# 使用export语法，使得变量可以传递到后续的脚本中
export DIR_SEPARATOR RUN_HOME

. "${RUN_HOME}${DIR_SEPARATOR}conf.sh"
. "${RUN_HOME}${DIR_SEPARATOR}func.sh"

# 如果第一个参数是 config 或 conf，则输出所有配置项
if [ "$1" = "config" ] || [ "$1" = "conf" ]; then
    echo "--------------基础配置------------------"
    echo "DIR_SEPARATOR: ${DIR_SEPARATOR}"
    echo "RUN_HOME: $RUN_HOME"
    echo "ODOO_DEPLOY_HOME: ${ODOO_DEPLOY_HOME}"
    show_conf
    # 如果第二个参数已设置且不为空
    if [ -n "$2" ]; then
        # 检查参数是否以--savefile=开头
        if echo "$2" | grep -q "^--savefile="; then
            # 提取--savefile=后面的文件名部分
            filename=$(echo "$2" | sed 's/^--savefile=//')
            echo "--------另存为配置文件(${filename})-----------------"
            save_config "${filename}"
        else
            echo "------config命令不支持参数($2)-------------"
            exit 1
        fi
        exit 0
    fi
fi

# 首次运行的时候，安装镜像和容器
if [ "$1" = "install" ]; then
    # 检查 ODOO_DEPLOY_HOME 目录是否存在
    if [ ! -d "${ODOO_DEPLOY_HOME}" ]; then
        echo "错误: Odoo 部署目录不存在: ${ODOO_DEPLOY_HOME}"
        exit 1
    fi

    # 启动 Postgres 容器
    PG_START_SCRIPT="${RUN_HOME}${DIR_SEPARATOR}postgres${DIR_SEPARATOR}start.sh"
    chmod +x "${PG_START_SCRIPT}"

    # 启动 Odoo容器
    ODOO_START_SCRIPT="${RUN_HOME}${DIR_SEPARATOR}odoo${DIR_SEPARATOR}install.sh"
    chmod +x "${ODOO_START_SCRIPT}"

    if [ "$2" = "pg" ] || [ "$2" = "postgres" ]; then
        sh "${PG_START_SCRIPT}"
        exit 0
    fi

    if [ "$2" = "odoo" ]; then
        sh "${ODOO_START_SCRIPT}"
        exit 0
    fi

    sh "${PG_START_SCRIPT}"
    sh "${ODOO_START_SCRIPT}"
    exit 0
fi

if [ "$1" = "update" ]; then
    ODOO_UPDATE_SCRIPT="${RUN_HOME}${DIR_SEPARATOR}odoo${DIR_SEPARATOR}update.sh"
    chmod +x "${ODOO_UPDATE_SCRIPT}"
    sh "${ODOO_UPDATE_SCRIPT}"
fi

if [ "$1" = "checkout" ]; then
    ODOO_CHECKOUT_SCRIPT="${RUN_HOME}${DIR_SEPARATOR}odoo${DIR_SEPARATOR}checkout.sh"
    export CHECKOUT_ARG="$2"
    chmod +x "${ODOO_CHECKOUT_SCRIPT}"
    sh "${ODOO_CHECKOUT_SCRIPT}"
fi

if [ "$1" = "docker" ]; then
    DOCKER_ARG="$2"
    if [ "$DOCKER_ARG" = "init" ]; then
        DOCKER_INIT_SCRIPT="${RUN_HOME}${DIR_SEPARATOR}docker${DIR_SEPARATOR}init_etc.sh"
        sh "${DOCKER_INIT_SCRIPT}"
        exit 0
    fi
    if [ "$DOCKER_ARG" = "recreate" ] || [ "$DOCKER_ARG" = "up" ] || [ "$DOCKER_ARG" = "down" ] || [ "$DOCKER_ARG" = "start" ] || [ "$DOCKER_ARG" = "stop" ] || [ "$DOCKER_ARG" = "restart" ] || [ "$DOCKER_ARG" = "logs" ] || [ "$DOCKER_ARG" = "ps" ] || [ "$DOCKER_ARG" = "rm" ]; then
        sh "${RUN_HOME}${DIR_SEPARATOR}docker${DIR_SEPARATOR}start.sh" "$DOCKER_ARG"
        exit 0
    fi
fi

if [ "$1" = "prepare" ]; then
    # 在当前Shell环境中执行prepare.sh脚本文件，而非启动子Shell
    # 因此，prepare.sh脚本的变量，不需要export，就能在当前Shell中使用。
    # 要让其他Shell也能使用这些变量，则需要使用export命令将它们导出。
    . "${RUN_HOME}${DIR_SEPARATOR}postgres${DIR_SEPARATOR}prepare.sh"
    . "${RUN_HOME}${DIR_SEPARATOR}odoo${DIR_SEPARATOR}prepare.sh"
fi
