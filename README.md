## 配置

使用环境变量 `ODOO_DEPLOY_HOME` 设置项目的部署目录。
或者直接从 `.env` 文件中读取 `ODOO_DEPLOY_HOME`。

`.env` 文件示例：

```
# 数据库名称
DB_NAME="postgres"

# 定义扩展模块的 Git 仓库 URL
ODOO_ADDONS_GIT_URL="http://127.0.0.1:8080/erp/odoo_addons.git"

# 定义 Odoo 部署目录
ODOO_DEPLOY_HOME=/root/erp
```

## 项目目录

- `odoo` - Odoo 相关
- `postgres` - PostgreSQL 相关
- `docker` - Docker 相关


## 项目文件

- `.env` - 环境变量配置
- `start.sh` - 项目启动脚本
