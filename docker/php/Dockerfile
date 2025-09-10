FROM composer:2 AS composer_src

FROM dunglas/frankenphp:1-php8.2

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends git zip unzip; \
    rm -rf /var/lib/apt/lists/*; \
    docker-php-ext-install pdo_mysql

COPY --from=composer_src /usr/bin/composer /usr/local/bin/composer

WORKDIR /var/www/html