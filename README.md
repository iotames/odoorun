## 快速开始

1. 克隆项目：git clone http://172.16.160.10:8929/santic/odoorun.git
2. 设置项目的部署目录：export ODOO_DEPLOY_HOME=/root/erp
3. 启动项目：sh ./odoorun/run.sh install

## 配置说明

除了使用 `环境变量` 外，还可以使用 `.env` 文件来配置项目。

`.env` 文件示例：

```
# 定义 Odoo 部署目录
ODOO_DEPLOY_HOME=/root/erp

# 数据库名称
DB_NAME="postgres"

# 定义扩展模块的 Git 仓库 URL
ODOO_ADDONS_GIT_URL="http://127.0.0.1:8080/erp/odoo_addons.git"
```

查看当前配置：

```shell 
sh run.sh config
```

## 项目目录

- `odoo` - Odoo 相关
- `postgres` - PostgreSQL 相关
- `docker` - Docker 相关


## 项目文件

- `.env` - 环境变量配置
- `start.sh` - 项目启动脚本
