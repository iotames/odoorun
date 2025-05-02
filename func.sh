#!/bin/sh

# 函数：更新requirements.tx
update_requirements() {
    # 进入$DOCKER_NAME_ODOO容器执行命令
    docker exec -it $DOCKER_NAME_ODOO /bin/bash -c "\
        if [ -f /mnt/extra-addons/requirements.txt ]; then \
            echo '检测到requirements.txt文件，开始安装依赖...' && \
            pip install -r /mnt/extra-addons/requirements.txt \
                -i https://mirrors.aliyun.com/pypi/simple/; \
        else \
            echo 'requirements.txt文件不存在，跳过依赖安装'; \
        fi"
}

# 函数：登录Harbor（支持HTTP/HTTPS）
login_harbor() {
    # 检查HARBOR_PASS是否为空
    if [ -z "$HARBOR_PASS" ]; then
        echo "HARBOR_PASS 密码为空。默认后续的docker操作不需要登录"
        return 0
    fi

    if ! docker login -u "$HARBOR_USER" -p "$HARBOR_PASS" "$HARBOR_URL"; then
        echo "Harbor登录失败！请检查："
        echo "1. Harbor地址是否正确: $HARBOR_URL"
        echo "2. 用户名密码是否正确（默认admin/Harbor12345）[5,8](@ref)"
        echo "3. 若使用HTTP，需在/etc/docker/daemon.json添加insecure-registries[7](@ref)"
        exit 1
    fi
}

# 函数：获取Harbor镜像。如：postgres:16.0 -> 172.16.160.33:9000/library/postgres:16.0
get_harbor_image() {
    local image_name="$1"
    
    # 获取IMAGE_PREFIX（去除协议头和末尾斜杠）
    IMAGE_PREFIX=$(echo "$HARBOR_URL" | sed -e 's|^https://||' -e 's|^http://||' -e 's|/$||')
    
    # 检查image_name格式，如果不包含斜杠，则添加library/前缀
    if ! echo "$image_name" | grep -q "/"; then
        image_name="library/$image_name"
    fi
    
    # 返回完整的Harbor镜像路径
    echo "$IMAGE_PREFIX/$image_name"
}

# 函数：检查镜像是否已存在本地
image_exists() {
    local image_name="$1"
    # 使用docker images --quiet快速检查（兼容Harbor和Docker Hub路径）
    if docker images --quiet "$image_name" | grep -q .; then
        # echo "镜像已存在本地: $image_name"
        return 0  # 存在
    else
        return 1  # 不存在
    fi
}

# 函数：检查容器是否已存在本地
container_exists() {
    local container_name="$1"
    # 使用docker ps --quiet快速检查
    if docker ps --quiet --filter name="$container_name" | grep -q .; then
        # echo "容器已存在本地: $container_name"
        return 0  # 存在
    else
        return 1  # 不存在
    fi
}

# 检查目录是否存在，不存在则创建并设置权限
check_and_mkdir() {
  local dirpath=$1
  if [ ! -d "$dirpath" ]; then
    # 挂载目录时注意是否有写入权限
    MKDIR_CMD="mkdir -p $dirpath && chmod 777 $dirpath"
    echo "执行命令: $MKDIR_CMD"
    eval "$MKDIR_CMD"
  fi
}

# 设置目录为Odoo容器的用户和组
chown_odoo_dir() {
  local dirpath=$1
  CHOWN_CMD="chown -R 101:101 $dirpath"
  echo "执行命令: $CHOWN_CMD"
  eval "$CHOWN_CMD"
}

# 函数：重启Docker服务使配置生效
restart_docker() {
    # 检测操作系统类型
    if [ "$(uname)" = "Darwin" ]; then
        # macOS系统
        echo "检测到macOS系统，重启Docker Desktop..."
        osascript -e 'quit app "Docker"'
        sleep 2
        open -a Docker
        # 等待Docker完全启动
        echo "等待Docker服务启动..."
        while ! docker info >/dev/null 2>&1; do
            sleep 1
        done
    else
        # Linux系统
        echo "检测到Linux系统，重启Docker服务..."
        # 尝试使用systemctl（适用于systemd系统）
        if command -v systemctl >/dev/null 2>&1; then
            systemctl restart docker
        # 尝试使用service（适用于旧版本Linux）
        elif command -v service >/dev/null 2>&1; then
            service docker restart
        else
            echo "无法识别服务管理器，请手动重启Docker服务"
            exit 1
        fi
    fi
    
    # 等待Docker服务完全启动
    echo "等待Docker服务就绪..."
    while ! docker info >/dev/null 2>&1; do
        sleep 1
    done
    echo "Docker服务已重启完成！"
}

# 函数：检查Docker是否已安装
check_docker_installed() {
    # 检查docker命令是否存在
    if ! command -v docker >/dev/null 2>&1; then
        echo "错误: Docker未安装！"
        echo "请先安装Docker:"
        
        # 根据操作系统提供安装建议
        if [ "$(uname)" = "Darwin" ]; then
            echo "macOS: 请访问 https://docs.docker.com/desktop/mac/install/ 下载安装Docker Desktop"
        elif [ "$(uname)" = "Linux" ]; then
            echo "Linux: 请参考 https://docs.docker.com/engine/install/ 选择适合您发行版的安装方法"
            # 检测常见Linux发行版
            if [ -f /etc/debian_version ]; then
                echo "Debian/Ubuntu: sudo apt-get update && sudo apt-get install docker-ce"
            elif [ -f /etc/redhat-release ]; then
                echo "CentOS/RHEL: sudo yum install docker-ce"
            fi
        elif [ "$(uname -s)" = "Windows_NT" ]; then
            echo "Windows: 请访问 https://docs.docker.com/desktop/windows/install/ 下载安装Docker Desktop"
        fi
        
        exit 1
    fi
}

# 函数：从配置文件内容中获取指定配置项的值
get_config_value() {
    local config_content="$1"  # 配置文件内容
    local config_key="$2"      # 要查找的配置项

    # 先检查配置项是否存在
    if ! echo "$config_content" | grep -q "^[[:space:]]*$config_key[[:space:]]*="; then
        # 配置项不存在，返回特定的错误标识或空字符串
        return 1  # 返回非零状态码表示未找到
    fi

    # 使用grep查找匹配的配置行，然后用awk提取值
    # -F '=' 指定分隔符为等号
    # 使用sed去除值两端的空格
    local value=$(echo "$config_content" | grep "^[[:space:]]*$config_key[[:space:]]*=" | awk -F '=' '{print $2}' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    
    echo "$value"
    return 0  # 返回成功状态码
}

# 定义通用配置项检查函数
add_config_if_missing() {
    local config_key="$1"
    local default_value="$2"
    local config_file="$3"
    
    # 检查配置项是否存在
    if value=$(get_config_value "$(cat "$config_file")" "$config_key"); then
        echo "配置项 ${config_key} 存在，值为: $value"
    else
        # 构造追加命令并执行
        local add_conf_cmd="echo \"${config_key} = ${default_value}\" >> ${config_file}"
        echo "配置项不存在。执行命令: $add_conf_cmd"
        eval "$add_conf_cmd"
    fi
}

# # /bin/sh 不支持使用 -f 导出函数
# export -f add_config_if_missing
# export -f get_config_value
# export -f check_docker_installed
# export -f restart_docker
# export -f chown_odoo_dir
# export -f check_and_mkdir
# export -f container_exists
# export -f image_exists
# export -f get_harbor_image
# export -f login_harbor
# export -f update_requirements
