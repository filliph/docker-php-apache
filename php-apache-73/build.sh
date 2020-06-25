#!/bin/bash

set -e

DOCKER_PHP_EXT_INSTALL="bcmath bz2 calendar dba exif gd gettext gmp iconv imap intl mbstring mysqli pdo_mysql pcntl pspell soap sockets xmlrpc xsl zip"
DOCKER_PHP_PECL_INSTALL="apcu igbinary memcached redis xdebug"

RUN_PACKAGES=""
TMP_PACKAGES=""
RUN_PACKAGES="$RUN_PACKAGES freetds-bin"
RUN_PACKAGES="$RUN_PACKAGES freetds-common"
RUN_PACKAGES="$RUN_PACKAGES freetds-dev"
RUN_PACKAGES="$RUN_PACKAGES libc-client2007e"
TMP_PACKAGES="$TMP_PACKAGES libgmp-dev"
TMP_PACKAGES="$TMP_PACKAGES libc-client2007e-dev"
RUN_PACKAGES="$RUN_PACKAGES libkrb5-dev"
TMP_PACKAGES="$TMP_PACKAGES libldap2-dev"
RUN_PACKAGES="$RUN_PACKAGES libmcrypt-dev"
RUN_PACKAGES="$RUN_PACKAGES libpspell-dev"
RUN_PACKAGES="$RUN_PACKAGES libxslt1-dev"
RUN_PACKAGES="$RUN_PACKAGES libzip-dev"
TMP_PACKAGES="$TMP_PACKAGES libfreetype6-dev"        # gd
RUN_PACKAGES="$RUN_PACKAGES libgd3"                  # gd
TMP_PACKAGES="$TMP_PACKAGES libgd-dev"               # gd
TMP_PACKAGES="$TMP_PACKAGES libjpeg62-turbo-dev"     # gd
RUN_PACKAGES="$RUN_PACKAGES libmagickwand-6.q16"     # imagick
TMP_PACKAGES="$TMP_PACKAGES libmagickwand-6.q16-dev" # imagick
TMP_PACKAGES="$TMP_PACKAGES libmemcached-dev"        # memcached
RUN_PACKAGES="$RUN_PACKAGES libmemcachedutil2"       # memcached
TMP_PACKAGES="$TMP_PACKAGES libpng-dev"              # gd
RUN_PACKAGES="$RUN_PACKAGES libssl-dev"
RUN_PACKAGES="$RUN_PACKAGES libbz2-dev"              # bz2
RUN_PACKAGES="$RUN_PACKAGES libxml2-dev"             # soap
RUN_PACKAGES="$RUN_PACKAGES libicu-dev"              # icu
RUN_PACKAGES="$RUN_PACKAGES libxpm4"                 # gd
TMP_PACKAGES="$TMP_PACKAGES libxpm-dev"              # gd
TMP_PACKAGES="$TMP_PACKAGES libwebp-dev"             # gd
RUN_PACKAGES="$RUN_PACKAGES mysql-client"
TMP_PACKAGES="$TMP_PACKAGES git"
RUN_PACKAGES="$RUN_PACKAGES unzip"
eval "apt update && apt upgrade -y && apt-get update && apt-get install --no-install-recommends -y $TMP_PACKAGES $RUN_PACKAGES"

eval "ln -s /usr/lib/x86_64-linux-gnu/libsybdb.a /usr/lib/"

case "$DOCKER_PHP_EXT_INSTALL" in 
  *gd*)
    echo 'Preparing module: gd...'
    docker-php-ext-configure gd \
        --with-gd=/usr/include \
        --with-freetype-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ \
        --with-png-dir=/usr/include/ \
        --with-webp-dir=/usr/include/ \
        --with-xpm-dir=/usr/include/
    ;;
esac

case "$DOCKER_PHP_EXT_INSTALL" in 
  *imap*)
    echo 'Preparing module: imap...'
    docker-php-ext-configure imap \
        --with-kerberos \
       	--with-imap-ssl
    ;;
esac

# for improved ASLR and optimizations
# https://github.com/docker-library/php/issues/105#issuecomment-278114879
export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS"

docker-php-source extract
eval "docker-php-ext-install $DOCKER_PHP_EXT_INSTALL"
eval "pecl install imagick $DOCKER_PHP_PECL_INSTALL"
eval "docker-php-ext-enable imagick $DOCKER_PHP_PECL_INSTALL"
/tmp/build_apache.sh
docker-php-source delete

# clean up
pecl clear-cache
rm -rf /tmp/* /var/lib/apt/lists/*
eval apt-mark manual "$RUN_PACKAGES"
eval "apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $TMP_PACKAGES"

# Enable mod_rewrite for apache images
a2enmod rewrite
service apache2 restart
