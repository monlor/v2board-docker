FROM alpine:3.11.5

ARG TARGETARCH

ENV CADDY_VERSION="1.0.4"

RUN apk update && \
    apk add --no-cache bash php7 curl supervisor redis \
    php7-zlib php7-xml php7-phar php7-intl php7-dom php7-xmlreader php7-ctype php7-session \
    php7-mbstring php7-tokenizer php7-gd php7-redis php7-bcmath \
    php7-iconv php7-pdo php7-posix php7-gettext php7-simplexml php7-sodium php7-sysvsem \
    php7-fpm php7-mysqli php7-json php7-openssl php7-curl php7-sockets php7-zip php7-pdo_mysql \
    php7-xmlwriter php7-opcache php7-gmp php7-pdo_sqlite php7-sqlite3 php7-pcntl php7-fileinfo && \
    wget https://github.com/caddyserver/caddy/releases/download/v${CADDY_VERSION}/caddy_v${CADDY_VERSION}_linux_${TARGETARCH}.tar.gz && \
    tar -zxvf caddy_v${CADDY_VERSION}_linux_${TARGETARCH}.tar.gz caddy -C /usr/local/bin && \
    rm -rf caddy_v${CADDY_VERSION}_linux_${TARGETARCH}.tar.gz && \
    mkdir -p /www /wwwlogs /run/php /run/caddy /run/supervisor
    
ENV COMPOSER_VERSION="2.5.5"

RUN apk add rsync && \
    curl -#Lo /usr/local/bin/composer https://getcomposer.org/download/${COMPOSER_VERSION}/composer.phar && \
    chmod +x /usr/local/bin/composer

ENV V2BOARD_VERSION="1.7.4"

RUN curl -#Lo /tmp/${V2BOARD_VERSION}.tar.gz https://github.com/v2board/v2board/archive/refs/tags/${V2BOARD_VERSION}.tar.gz && \
    mkdir -p /tmp/www && cd /tmp/www && \
    tar zxvf /tmp/${V2BOARD_VERSION}.tar.gz --strip 1 -C /tmp/www && \
    composer install -vvv && \
    rm -rf ~/.composer/cache /tmp/${V2BOARD_VERSION}.tar.gz

COPY rules /tmp/www/resources/rules

COPY mail /tmp/www/resources/views/mail

COPY app /tmp/www/app

COPY entrypoint.sh /entrypoint.sh

COPY crontabs.conf /etc/crontabs/root

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY supervisord-run.conf /run/supervisor/supervisord.conf

COPY www.conf /etc/php7/php-fpm.d/www.conf

RUN chmod +x /entrypoint.sh && \
    touch /wwwlogs/queue.log /wwwlogs/horizon.log 

ENTRYPOINT ["/entrypoint.sh"]

CMD []