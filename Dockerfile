FROM monlor/v2board-lcrp

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

COPY supervisord.conf /run/supervisor/supervisord.conf

RUN chmod +x /entrypoint.sh && \
    touch /wwwlogs/queue.log /wwwlogs/horizon.log 

ENTRYPOINT ["/entrypoint.sh"]

CMD []