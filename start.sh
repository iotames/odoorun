#!/bin/bash

# 如果存在 .env 文件，从中读取环境变量
if [ -f .env ]; then
    # https://stackoverflow.com/questions/19331497/set-environment-variables-from-file-of-key-value-pairs
    export $(cat .env | sed 's/#.*//g' | xargs)
fi

# 获取目录分隔符：如果不存在 DIR_SEPARATOR 环境变量，设置为 '/'
if [ -z ${DIR_SEPARATOR} ]; then
    DIR_SEPARATOR=='/'
fi

# 获取 Odoo 部署目录：如果不存在 ODOO_DEPLOY_HOME 环境变量，设置为用户家目录 HOME
if [ -z ${ODOO_DEPLOY_HOME} ]; then
    ODOO_DEPLOY_HOME=${HOME}
fi

echo "ODOO_DEPLOY_HOME=${ODOO_DEPLOY_HOME}"

echo "DIR_SEPARATOR=${DIR_SEPARATOR}"
bash ${ODOO_DEPLOY_HOME}${DIR_SEPARATOR}odoo${DIR_SEPARATOR}start.sh
