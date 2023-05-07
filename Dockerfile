FROM monlor/v2board-lcrp

ENV COMPOSER_VERSION="2.5.5"

RUN curl -#Lo /usr/local/bin/composer https://getcomposer.org/download/${COMPOSER_VERSION}/composer.phar && \
    chmod +x /usr/local/bin/composer

ENV V2BOARD_VERSION="1.7.3"

RUN curl -#Lo /tmp/${V2BOARD_VERSION}.tar.gz https://github.com/v2board/v2board/archive/refs/tags/${V2BOARD_VERSION}.tar.gz && \
    tar zxvf /tmp/${V2BOARD_VERSION}.tar.gz --strip 1 -C /www && \
    composer install -vvv && \
    rm -rf ~/.composer/cache /tmp/${V2BOARD_VERSION}.tar.gz

COPY entrypoint.sh /entrypoint.sh

COPY crontabs.conf /etc/crontabs/root

COPY supervisord.conf /run/supervisor/supervisord.conf

RUN chmod +x /entrypoint.sh && \
    touch /wwwlogs/queue.log /wwwlogs/horizon.log 

ENTRYPOINT ["/entrypoint.sh"]

CMD []