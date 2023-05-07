#!/bin/sh

cat > /run/caddy/caddy.conf <<-EOF
${HOME_URL:-http://localhost} {
    root /www/public
    log /wwwlogs/caddy.log
    fastcgi / /tmp/php-cgi.sock php
    rewrite {
        to {path} {path}/ /index.php?{query}
    }
}
EOF

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
