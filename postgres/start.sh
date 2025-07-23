#/bin/sh

# 在当前Shell环境中执行prepare.sh脚本文件，而非启动子Shell
# 因此，prepare.sh脚本的变量，不需要export，就能在当前Shell中使用。
# 要让其他Shell也能使用这些变量，则需要使用export命令将它们导出。
. "${RUN_HOME}${DIR_SEPARATOR}postgres${DIR_SEPARATOR}prepare.sh"

# 启动容器
if container_exists "$DOCKER_NAME_DB"; then
    echo "容器 $DOCKER_NAME_DB 已存在"
else
    # 构建完整的docker run命令
    DOCKER_CMD="docker run --restart=always -d \
      -e POSTGRES_USER=$DB_USER \
      -e POSTGRES_PASSWORD=$DB_PASSWORD \
      -e POSTGRES_DB=$DB_NAME \
      -v $PG_DATA_DIR:/var/lib/postgresql/data \
      -p $DB_PORT:5432 \
      -u $PUID:$PGID \
      --name $DOCKER_NAME_DB \
      $DOCKER_IMAGE_DB"
    
    # 打印命令
    echo "执行命令: $DOCKER_CMD"
    
    # 执行命令
    eval "$DOCKER_CMD"
fi

# --restart always \
# docker run -d -e POSTGRES_USER=odoo -e POSTGRES_PASSWORD=odoo -e POSTGRES_DB=postgres --name db postgres:15
# docker run -d --env-file $ENV_FILE --name db postgres:15