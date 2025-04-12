#!/bin/sh

# 配置变量
# HARBOR_URL="harbor.example.com"  # 替换为你的Harbor地址
HARBOR_USER="admin"              # 默认管理员用户名
HARBOR_PASS="Harbor12345"        # 替换为你的Harbor密码（建议从安全途径获取）

# 函数：登录Harbor（支持HTTP/HTTPS）
login_harbor() {
    if ! docker login -u "$HARBOR_USER" -p "$HARBOR_PASS" "$HARBOR_URL"; then
        echo "Harbor登录失败！请检查："
        echo "1. Harbor地址是否正确: $HARBOR_URL"
        echo "2. 用户名密码是否正确（默认admin/Harbor12345）[5,8](@ref)"
        echo "3. 若使用HTTP，需在/etc/docker/daemon.json添加insecure-registries[7](@ref)"
        exit 1
    fi
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
