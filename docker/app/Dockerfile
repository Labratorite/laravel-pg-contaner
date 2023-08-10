FROM php:8.0-fpm-buster
COPY php.ini /usr/local/etc/php/

RUN apt-get update \
    && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libzip-dev \
        zlib1g-dev \
        unzip \
        vim \
        libonig-dev \
        git \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
        gd \
        zip \
        pdo_mysql \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && groupadd -g 1000 php \
    && useradd -u 1000 -ms /bin/bash -g php uptalk

ENV TZ=Asia/Tokyo \
  COMPOSER_ALLOW_SUPERUSER=1 \
  COMPOSER_HOME=/composer

COPY --from=composer:2.1 /usr/bin/composer /usr/bin/composer

ENV COMPOSER_ALLOW_SUPERUSER 1

ENV COMPOSER_HOME /composer

ENV PATH $PATH:/composer/vendor/bin

WORKDIR /var/www/html

# ユーザーを作成
ARG DOCKER_UID=1000

# 作成したユーザーに切り替える
USER ${DOCKER_USER}
