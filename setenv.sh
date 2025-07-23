#!/bin/bash

export ODOO_DEPLOY_HOME=/home/myname/erp
export DOCKER_IMAGE_DB=172.16.160.33:9000/library/postgres:17.4-bookworm
export DOCKER_IMAGE_ODOO=172.16.160.33:9000/library/odoo:17.0-20250401
export DOCKER_NAME_DB=odoodb
export DOCKER_NAME_ODOO=odooweb
export ODOO_WEB_PORT=8080
export ODOO_DATA=/home/myname/erp/odoo/data
export ODOO_CONFIG=/home/myname/erp/odoo/config
export ODOO_ADDONS=/home/myname/erp/odoo/addons
export ODOO_LOG=/home/myname/erp/odoo/log
export ODOO_ADDONS_PATH=/mnt/extra-addons
# export ODOO_ADDONS_GIT_URL=
export ODOO_ADDONS_GIT_BRANCH=dev
export DB_PORT=5432
export DB_NAME=postgres
export DB_USER=odoo
export DB_PASSWORD=odoo
export PG_DATA_DIR=/home/myname/erp/postgres/data
# export HARBOR_URL=
export ODOO_UPDATE_MODULES=product

# docker compose up -d
