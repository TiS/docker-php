FROM php:7.0
RUN apt-get update
RUN apt-get install -y \
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
        libmcrypt-dev \
        libpng-dev
RUN pecl install memcached-3.0.3
RUN curl -Ss --location --output /usr/local/bin/phpunit https://phar.phpunit.de/phpunit.phar \
    && chmod +x /usr/local/bin/phpunit
RUN docker-php-ext-install -j$(nproc) iconv mcrypt pdo_mysql intl interbase zip \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd
RUN docker-php-ext-enable memcached
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
