## 快速开始

1. 克隆项目：git clone http://172.16.160.10:8929/santic/odoorun.git
2. 设置项目的部署目录：export ODOO_DEPLOY_HOME=/root/erp
3. 查看当前配置：`./odoorun/run.sh config`
4. 初始化Docker：`./odoorun/run.sh docker init` (配置国内镜像源，加速下载)
5. 安装Odoo项目：`./odoorun/run.sh install`


## 配置说明

除了使用 `环境变量` 外，还可以使用 `.env` 文件来配置项目。

`.env` 文件示例：

```
# 定义 Odoo 部署目录
ODOO_DEPLOY_HOME=/root/erp

# 定义扩展模块的 Git 仓库 URL
ODOO_ADDONS_GIT_URL="http://127.0.0.1:8080/erp/odoo_addons.git"

# 定义容器内部的扩展模块目录
ODOO_ADDONS_PATH="/mnt/extra-addons"

# 也可以配置Harbor仓库来下载Docker镜像：
# HARBOR_URL="harbor.example.com"  # 替换为你的Harbor地址
# HARBOR_USER="admin"              # 默认管理员用户名
# HARBOR_PASS="Harbor12345"        # 替换为你的Harbor密码（建议从安全途径获取）

# 也可以设置HTTP_PROXY和HTTPS_PROXY：
HTTP_PROXY="socks5://127.0.0.1:7890"
HTTPS_PROXY="socks5://127.0.0.1:7890"
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

- `run.sh` - 项目启动脚本
- `.env` - 环境变量配置。可以不用放在 `run.sh` 同级目录下。在哪个目录启动 `run.sh`，就会从哪个目录加载 `.env` 文件。
