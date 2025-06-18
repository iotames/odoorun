#!/bin/sh

# 如果存在 .env 文件，从中读取环境变量
if [ -f .env ]; then
    # https://stackoverflow.com/questions/19331497/set-environment-variables-from-file-of-key-value-pairs
    echo "发现.env文件，加载环境变量......"
    export $(cat .env | sed 's/#.*//g' | xargs)
fi

# 获取 Odoo 部署目录：如果不存在 ODOO_DEPLOY_HOME 环境变量，设置为当前项目根目录
if [ -z "${ODOO_DEPLOY_HOME}" ]; then
    ODOO_DEPLOY_HOME=$(pwd)
fi

if [ -z "${DOCKER_IMAGE_DB}" ]; then
    DOCKER_IMAGE_DB="postgres:17.4-bookworm"
fi

if [ -z "${DOCKER_IMAGE_ODOO}" ]; then
    DOCKER_IMAGE_ODOO="odoo:17.0-20250401"
fi

if [ -z "${DOCKER_NAME_DB}" ]; then
    DOCKER_NAME_DB='odoodb'
fi

if [ -z "${DOCKER_NAME_ODOO}" ]; then
    DOCKER_NAME_ODOO='odooweb'
fi

if [ -z "${ODOO_WEB_PORT}" ]; then
    ODOO_WEB_PORT=8069
fi

if [ -z "${ODOO_DATA}" ]; then
    ODOO_DATA="$ODOO_DEPLOY_HOME${DIR_SEPARATOR}odoo${DIR_SEPARATOR}data"
fi

if [ -z "${ODOO_CONFIG}" ]; then
    ODOO_CONFIG="$ODOO_DEPLOY_HOME${DIR_SEPARATOR}odoo${DIR_SEPARATOR}config"
fi

if [ -z "${ODOO_ADDONS}" ]; then
    ODOO_ADDONS="$ODOO_DEPLOY_HOME${DIR_SEPARATOR}odoo${DIR_SEPARATOR}addons"
fi

if [ -z "${ODOO_LOG}" ]; then
    ODOO_LOG="$ODOO_DEPLOY_HOME${DIR_SEPARATOR}odoo${DIR_SEPARATOR}log"
fi

# 容器内部的addons_path路径
if [ -z "${ODOO_ADDONS_PATH}" ]; then
    ODOO_ADDONS_PATH="/mnt/extra-addons"
fi

if [ -z "${DB_PORT}" ]; then
    DB_PORT=5432
fi

if [ -z "${DB_NAME}" ]; then
    # 初始化数据库，默认使用postgres。不要使用odoo，否则容器内部出现-i base报错
    DB_NAME='postgres'
fi

if [ -z "${DB_USER}" ]; then
    DB_USER='odoo'
fi

if [ -z "${DB_PASSWORD}" ]; then
    DB_PASSWORD='odoo'
fi

if [ -z "${PG_DATA_DIR}" ]; then
    PG_DATA_DIR="${ODOO_DEPLOY_HOME}${DIR_SEPARATOR}postgres${DIR_SEPARATOR}data"
fi

if [ -z "${ODOO_ADDONS_GIT_BRANCH}" ]; then
    ODOO_ADDONS_GIT_BRANCH='dev'
fi

# if [ -z "${ODOO_UPDATE_MODULES}" ]; then
#     ODOO_UPDATE_MODULES='all'
# fi

show_conf() {
    echo "-------------容器基础配置--------------------"
    echo "DOCKER_IMAGE_DB: ${DOCKER_IMAGE_DB}"
    echo "DOCKER_IMAGE_ODOO: ${DOCKER_IMAGE_ODOO}"
    echo "DOCKER_NAME_DB: ${DOCKER_NAME_DB}"
    echo "DOCKER_NAME_ODOO: ${DOCKER_NAME_ODOO}"
    echo "HARBOR_URL: ${HARBOR_URL}"
    echo "HARBOR_USER: ${HARBOR_USER}"
    echo "HARBOR_PASS: ${HARBOR_PASS}"
    echo "--------------数据库容器配置-------------------"
    echo "DB_PORT: ${DB_PORT}"
    echo "DB_NAME: ${DB_NAME}"
    echo "DB_USER: ${DB_USER}"
    echo "DB_PASSWORD: ${DB_PASSWORD}"
    echo "PG_DATA_DIR: ${PG_DATA_DIR}"
    echo "--------------Odoo容器配置-------------------"
    echo "ODOO_WEB_PORT: ${ODOO_WEB_PORT}"
    echo "ODOO_DATA: ${ODOO_DATA}"
    echo "ODOO_CONFIG: ${ODOO_CONFIG}"
    echo "ODOO_ADDONS: ${ODOO_ADDONS}"
    echo "ODOO_LOG: ${ODOO_LOG}"
    echo "--------------Odoo应用配置-------------------"
    echo "ODOO_ADDONS_PATH: ${ODOO_ADDONS_PATH}"
    echo "ODOO_ADDONS_GIT_URL: ${ODOO_ADDONS_GIT_URL}"
    echo "ODOO_ADDONS_GIT_BRANCH: ${ODOO_ADDONS_GIT_BRANCH}"
    echo "ODOO_UPDATE_MODULES: ${ODOO_UPDATE_MODULES}"
}

# 配置变量
# HARBOR_URL="harbor.example.com"  # 替换为你的Harbor地址
# HARBOR_USER="admin"              # 默认管理员用户名
# HARBOR_PASS="Harbor12345"        # 替换为你的Harbor密码（建议从安全途径获取）

export ODOO_DEPLOY_HOME
export DOCKER_IMAGE_DB
export DOCKER_IMAGE_ODOO
export DOCKER_NAME_DB
export DOCKER_NAME_ODOO
export ODOO_WEB_PORT
export ODOO_DATA
export ODOO_CONFIG
export ODOO_ADDONS
export ODOO_LOG
export ODOO_ADDONS_PATH
export ODOO_ADDONS_GIT_URL
export ODOO_ADDONS_GIT_BRANCH
export ODOO_UPDATE_MODULES
export DB_PORT
export DB_NAME
export DB_USER
export DB_PASSWORD
export PG_DATA_DIR
export HARBOR_URL
export HARBOR_USER
export HARBOR_PASS
