FROM php:7.1.3-fpm-alpine

MAINTAINER James C Garrett

RUN set -ex \
    && apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS imagemagick-dev libtool \
    && export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS" \
    && pecl install imagick-3.4.3 \
    && docker-php-ext-enable imagick \
    && apk add --no-cache --virtual .imagick-runtime-deps imagemagick \
    && apk del .phpize-deps

RUN apk update \
    && apk add  --no-cache git mysql-client curl libmcrypt libmcrypt-dev \
    libxml2-dev freetype-dev libpng-dev libjpeg-turbo-dev g++ make autoconf \
    && docker-php-source extract \
    && docker-php-source delete \
    && docker-php-ext-install mcrypt pdo_mysql soap \
    && echo "xdebug.remote_enable=on\n" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_autostart=off\n" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_port=9000\n" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_handler=dbgp\n" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_connect_back=0\n" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && rm -rf /tmp/*

WORKDIR /var/www