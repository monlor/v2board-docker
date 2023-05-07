#!/bin/bash

echo "更新v2board文件..."
if [ -f /www/.env ]; then
    cp -f /www/.env /tmp/www
fi
rm -rf /www/{*,.[^.]*}
cp -rf /tmp/www/{*,.[^.]*} /www

echo "生成Caddy配置文件..."
if echo ${HOME_URL} | grep -Eq "^https"; then
        cat > /run/caddy/caddy.conf <<-EOF
${HOME_URL} {
    root /www/public
    log /wwwlogs/caddy.log
    tls ${CADDY_EMAIL:-admin@example.com}
    fastcgi / /tmp/php-cgi.sock php
    rewrite {
        to {path} {path}/ /index.php?{query}
    }
}
EOF
else
    cat > /run/caddy/caddy.conf <<-EOF
${HOME_URL:-0.0.0.0:80} {
    root /www/public
    log /wwwlogs/caddy.log
    fastcgi / /tmp/php-cgi.sock php
    rewrite {
        to {path} {path}/ /index.php?{query}
    }
}
EOF
fi

cat <<-EOF
============================================
首次启动时需要执行以下操作：
1. 进入容器：docker exec -it v2board /bin/bash
2. 初始化数据库：php artisan v2board:install
3. 启动服务：php artisan horizon &
4. 退出容器：exit
============================================
EOF

/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
