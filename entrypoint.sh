#!/bin/bash

set -u

if [ ! -f /data/.env ]; then
    cp -rf /www/.env.example /data/.env
fi

if [ ! -f /data/v2board.php ]; then
    touch /data/v2board.php
fi

echo "创建v2board软链接..."
ln -sf /data/.env /www/.env
ln -sf /data/v2board.php /www/config/v2board.php

echo "生成Caddy配置文件..."
echo -n > /run/caddy/caddy.conf
echo "${HOME_URL}" | tr ',' '\n' | while read url; do
    if echo "${url}" | grep -Eq "^https"; then
        cat >> /run/caddy/caddy.conf <<-EOF
${url} {
    root /www/public
    log /wwwlogs/caddy.log
    tls ${CADDY_EMAIL:-admin@example.com}
    gzip
    fastcgi / /tmp/php-cgi.sock php
    rewrite {
        to {path} {path}/ /index.php?{query}
    }
}

${url/https/http} {
    redir https://{host}{uri}
}
EOF
    else
        cat >> /run/caddy/caddy.conf <<-EOF
${url} {
    root /www/public
    log /wwwlogs/caddy.log
    fastcgi / /tmp/php-cgi.sock php
    gzip
    rewrite {
        to {path} {path}/ /index.php?{query}
    }
}
EOF
    fi
done

cat <<-EOF
============================================
首次启动时需要执行以下操作：
1. 进入容器：docker exec -it v2board /bin/bash
2. 初始化数据库：php artisan v2board:install
3. 启动服务：php artisan horizon &
4. 退出容器：exit

后续更新v2board：
1. 备份docker卷数据
2. 拉取最新镜像启动服务
2. 执行更新命令：docker exec -it v2board /usr/bin/php artisan v2board:update
============================================
EOF

/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
