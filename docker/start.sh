#!/bin/sh

DOCKER_COMPOSE_FILE="${RUN_HOME}${DIR_SEPARATOR}docker${DIR_SEPARATOR}docker-compose.yml"

# docker-compose 可能在子Shell执行，故export导出变量
export DOCKER_IMAGE_ODOO
export DOCKER_NAME_ODOO
export ODOO_WEB_PORT
export ODOO_DATA
export ODOO_CONFIG
export ODOO_ADDONS
export ODOO_LOG
export DOCKER_IMAGE_DB
export DOCKER_NAME_DB
export DB_NAME
export DB_USER
export DB_PASSWORD
export DB_PORT
export PG_DATA_DIR
export ODOO_UPDATE_MODULES


# 检查系统是否存在docker-compose命令
if command -v docker-compose >/dev/null 2>&1; then
    DOCKER_CMD="docker-compose"
else
    # 如果不存在docker-compose，则使用docker compose
    DOCKER_CMD="docker compose"
fi

CMD_ARG="$1"
FULL_CMD=""

case "$CMD_ARG" in
    "recreate")
        FULL_CMD="$DOCKER_CMD -f ${DOCKER_COMPOSE_FILE} up -d --force-recreate"
        ;;
    "up")
        FULL_CMD="$DOCKER_CMD -f ${DOCKER_COMPOSE_FILE} up -d"
        ;;
    "down")
        FULL_CMD="$DOCKER_CMD -f ${DOCKER_COMPOSE_FILE} down"
        ;;
    "start")
        FULL_CMD="$DOCKER_CMD -f ${DOCKER_COMPOSE_FILE} start"
        ;;
    "stop")
        FULL_CMD="$DOCKER_CMD -f ${DOCKER_COMPOSE_FILE} stop"
        ;;
    "restart")
        FULL_CMD="$DOCKER_CMD -f ${DOCKER_COMPOSE_FILE} restart"
        ;;
    "logs")
        FULL_CMD="$DOCKER_CMD -f ${DOCKER_COMPOSE_FILE} logs"
        ;;
    "ps")
        FULL_CMD="$DOCKER_CMD -f ${DOCKER_COMPOSE_FILE} ps"
        ;;
    "rm")
        FULL_CMD="$DOCKER_CMD -f ${DOCKER_COMPOSE_FILE} rm -f"
        ;;
    *)
        # 显示使用帮助
        echo "用法: $0 {recreate|up|down|start|stop|restart|logs|ps|rm}"
        exit 1
        ;;
esac

# 执行最终命令
echo "执行命令: $FULL_CMD"
eval "$FULL_CMD"

# tail -n 90 -f odoo/log/myodoo.log
# ./odoo-bin --save --config=odoo.conf 将当前配置保存到文件，便于复用
# odoo-bin -i sale,purchase --stop-after-init
# -u base,sale --stop-after-init
# docker exec odooweb odoo-bin -i module1,module2 -d your_db --stop-after-init
# --without-demo=all 初始化数据库时不加载测试数据
# --workers=4 设置HTTP工作进程数（CPU核心数×2+1），提升并发处理能力
# -u all 确保数据库结构更新. 需配合 -d 指定数据库使用
# --dev=reload 仅适用于开发环境，不涉及数据库结构变更. 需安装 watchdog 包监控文件变化，否则无效. 对 XML/视图文件的修改可能仍需刷新页面或搭配 --dev=xml 参数
# --dev=xml 允许 XML 修改后刷新页面生效
# docker exec -it odoo bash
# rm -rf /var/lib/odoo/*.pyc  # 删除Python编译缓存
# service odoo restart        # 重启服务


# # 1. 备份数据库
# pg_dump prod_db > backup.sql

# # 2. 执行模块更新
# odoo-bin -u my_module -d prod_db --stop-after-init

# # 3. 验证更新结果
# curl -X POST http://localhost:8069/web/dataset/call_kw \
#   -d '{
#     "method": "check_module_state",
#     "args": ["my_module"],
#     "kwargs": {}
#   }'


# docker run -d --name odoo_dev \
#   -p 8069:8069 \
#   -v ./odoo_data:/var/lib/odoo \
#   odoo:17.0 \
#   odoo --dev=reload -u all --log-level=debug --without-demo=all

# -e INSTALL_MODULES=base
# "-- -i base" 整个命令参数，放在Docker命令的末尾
# --restart always 容器退出后自动重启
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