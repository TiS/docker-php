FROM php:7.3
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
        mariadb-client \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libldap2-dev \
        libpng-dev \
        libxml2-dev \
        libzip-dev
RUN pecl install memcached-3.1.3
RUN pecl install xdebug-2.7.2
RUN curl -Ss --location --output /usr/local/bin/phpunit https://phar.phpunit.de/phpunit.phar \
    && chmod +x /usr/local/bin/phpunit
RUN docker-php-ext-install -j$(nproc) iconv
RUN docker-php-ext-install -j$(nproc) intl
RUN docker-php-ext-install -j$(nproc) interbase
RUN docker-php-ext-install -j$(nproc) pdo_mysql
RUN docker-php-ext-install -j$(nproc) soap
RUN docker-php-ext-install -j$(nproc) zip
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install -j$(nproc) gd
RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/
RUN docker-php-ext-install ldap
RUN docker-php-ext-enable memcached xdebug
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
