#!/bin/sh

. "${RUN_HOME}${DIR_SEPARATOR}conf.sh"
. "${RUN_HOME}${DIR_SEPARATOR}func.sh"

# 检查是否存在.git目录
if [ -d "${ODOO_ADDONS}/.git" ]; then
    echo "------检测到${ODOO_ADDONS}目录存在.git"
    CD_CMD="cd $ODOO_ADDONS"
    echo "------执行命令: $CD_CMD"
    eval "$CD_CMD"

    if [ -z "$CHECKOUT_ARG" ]; then
        echo "------未指定tag，使用最新tag"
        CHECKOUT_ARG=`git tag -l | sort -V | tail -n 1`
    fi
    echo "------切换到tag: $CHECKOUT_ARG"
    SWITCH_CMD="git pull origin ${ODOO_ADDONS_GIT_BRANCH}:${ODOO_ADDONS_GIT_BRANCH} && \
git switch ${ODOO_ADDONS_GIT_BRANCH} && git fetch --tags && \
git checkout $CHECKOUT_ARG"
    echo "------执行命令: $SWITCH_CMD"
    eval "$SWITCH_CMD"
else
    echo "------${ODOO_ADDONS}目录下不存在.git目录，跳过..."
fi

# 重启ODOO容器
docker restart $DOCKER_NAME_ODOO
if [ $? -eq 0 ]; then
    echo "------ODOO容器重启成功"
else
    echo "------ODOO容器重启失败"
fi

# RUN_CMD="/xxx/venv/bin/python /xxx/erp/odoo17/odoo-bin -c /xxx/erp/erp.conf"
# runpid=`ps aux | grep "$RUN_CMD" | awk 'NR==1{print}' | awk '{print $2}'`
# kill $runpid
# nohup $RUN_CMD > /home/santic/erp/odoo17ce.run.log 2>&1 &
