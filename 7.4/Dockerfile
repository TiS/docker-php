# https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
ARG PHP_VERSION=7.4

FROM php:${PHP_VERSION} AS symfony_php
ARG DEBIAN_VERSION=11
ARG XLSWRITER_VERSION=1.5.2
ARG MEMCACHED_VERSION=3.2.0
ARG SQLSRV_VERSION=5.10.1
ARG PDO_SQLSRV_VERSION=5.10.1
ARG XDEBUG_VERSION=3.1.4

# https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV PATH="${PATH}:/root/.composer/vendor/bin"

## Persistent / runtime deps
RUN set -eux; \
    curl https://packages.microsoft.com/keys/microsoft.asc > /usr/share/keyrings/microsoft.asc; \
    curl https://packages.microsoft.com/config/debian/${DEBIAN_VERSION}/prod.list \
      | sed -E "s/(\[)(.*)(\])/\1\2 signed-by=\/usr\/share\/keyrings\/microsoft.asc\3/" \
      > /etc/apt/sources.list.d/mssql-release.list; \
    apt-get update; \
    ACCEPT_EULA=Y apt-get install -y \
      acl \
      bash \
      zip \
      unzip \
      software-properties-common \
      libfcgi-bin \
      nodejs \
      git \
      wget \
      mariadb-client \
      # MSSQL requirements
      msodbcsql18 \
      # GD requirements
      libjpeg62-turbo \
      libpng16-16 \
      libfreetype6 \
      # MEMCACHED requirements
      libmemcached11 \
      libmemcachedutil2 \
      # ZIP requirements
      libzip4 \
      # Firebird requirements
      libfbclient2; \
    # CLEANUP
    apt clean -y; \
    rm -rf /var/lib/apt/lists/*;

RUN set -eux; \
    apt-get update; \
    apt-get install -y \
      libfreetype6-dev \
      libjpeg62-turbo-dev \
      libpng-dev \
      libmemcached-dev \
      zlib1g-dev \
      libicu-dev \
      libzip-dev \
      libldap2-dev \
      firebird-dev \
      libxml2-dev \
      zlib1g-dev \
      unixodbc-dev; \
    # apt cleanup
    apt-get clean -y; \
    rm -rf /var/lib/apt/lists/*; \
    # Actual extensions install
    docker-php-ext-configure gd --with-freetype --with-jpeg; \
    pecl install memcached-${MEMCACHED_VERSION}; \
    pecl install xlswriter-${XLSWRITER_VERSION}; \
    pecl install sqlsrv-${SQLSRV_VERSION}; \
    pecl install pdo_sqlsrv-${SQLSRV_VERSION}; \
    pecl install xdebug-${XDEBUG_VERSION}; \
    docker-php-ext-configure intl; \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/; \
    docker-php-ext-install -j$(nproc) gd iconv intl pdo pdo_mysql zip ldap pdo_firebird soap; \
    docker-php-ext-enable memcached xlswriter sqlsrv pdo_sqlsrv xdebug; \
    ## Cleanup build time dependencies
    apt-get remove -y --purge \
      libfreetype6-dev \
      libjpeg62-turbo-dev \
      libpng-dev \
      libmemcached-dev \
      zlib1g-dev \
      libicu-dev \
      libzip-dev \
      libldap2-dev \
      firebird-dev \
      libxml2-dev \
      zlib1g-dev \
      unixodbc-dev; \
    apt-get autoremove -y; \
    apt-get clean -y; \
    rm -rf /var/lib/apt/lists/*;

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN curl -Ss --location --output /usr/local/bin/phpunit https://phar.phpunit.de/phpunit.phar && chmod +x /usr/local/bin/phpunit
