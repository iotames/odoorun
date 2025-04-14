#!/bin/sh

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
    ODOO_DATA="$ODOO_DEPLOY_HOME/odoo/data"
fi

if [ -z "${ODOO_CONFIG}" ]; then
    ODOO_CONFIG="$ODOO_DEPLOY_HOME/odoo/config"
fi

if [ -z "${ODOO_ADDONS}" ]; then
    ODOO_ADDONS="$ODOO_DEPLOY_HOME/odoo/addons"
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

show_conf() {
    echo "DOCKER_IMAGE_DB: ${DOCKER_IMAGE_DB}"
    echo "DOCKER_IMAGE_ODOO: ${DOCKER_IMAGE_ODOO}"
    echo "DOCKER_NAME_DB: ${DOCKER_NAME_DB}"
    echo "DOCKER_NAME_ODOO: ${DOCKER_NAME_ODOO}"
    echo "ODOO_WEB_PORT: ${ODOO_WEB_PORT}"
    echo "ODOO_DATA: ${ODOO_DATA}"

    echo "DB_PORT: ${DB_PORT}"
    echo "DB_NAME: ${DB_NAME}"
    echo "DB_USER: ${DB_USER}"
    echo "DB_PASSWORD: ${DB_PASSWORD}"
}
