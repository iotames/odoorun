#!/bin/sh

if [ -z "${DOCKER_NAME_DB}" ]; then
    DOCKER_NAME_DB='db-pg17'
fi

if [ -z "${DOCKER_NAME_ODOO}" ]; then
    DOCKER_NAME_ODOO='odoo17-erp'
fi

if [ -z "${DOCKER_IMAGE_DB}" ]; then
    DOCKER_IMAGE_DB="postgres:17.4-bookworm"
fi

if [ -z "${DOCKER_IMAGE_ODOO}" ]; then
    DOCKER_IMAGE_ODOO="odoo:17.0-20250401"
fi

if [ -z "${ODOO_WEB_PORT}" ]; then
    ODOO_WEB_PORT=8080
fi

if [ -z "${ODOO_DATA}" ]; then
    ODOO_DATA="./odoo/data"
fi

if [ -z "${DB_PORT}" ]; then
    DB_PORT=5432
fi
if [ -z "${DB_NAME}" ]; then
    DB_NAME='postgres'
fi
if [ -z "${DB_USER}" ]; then
    DB_USER='postgres'
fi
if [ -z "${DB_PASSWORD}" ]; then
    DB_PASSWORD='postgres'
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
