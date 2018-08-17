FROM php:7.2
RUN apt-get update && apt-get install -y \
        nodejs \
        git \
        wget \
        libmemcached-dev \
        zlib1g-dev \
        libicu-dev \
        zlib1g-dev \
        firebird-dev \
        unzip \
        mysql-client \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libxml2-dev
RUN pecl install memcached-3.0.4 \
    && pecl install xdebug-2.6.0
RUN curl -Ss --location --output /usr/local/bin/phpunit https://phar.phpunit.de/phpunit.phar \
    && chmod +x /usr/local/bin/phpunit
RUN docker-php-ext-install -j$(nproc) iconv pdo_mysql intl interbase zip soap \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd
RUN docker-php-ext-enable memcached xdebug soap
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
