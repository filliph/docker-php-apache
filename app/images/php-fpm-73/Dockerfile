FROM php:7.3-fpm-buster

RUN set -xe; \
    apt-get update \
    && apt-get install -y \
        # for bz2
        libbz2-dev \
        # for gmp
        libgmp-dev \
        # for imap
        libc-client-dev \ 
        libkrb5-dev \
        # for intl extension
        libicu-dev \
        # for gd
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        # for mbstring
        libonig-dev \
        # memchached extension
        libmemcached-dev \
        # for pspell
        libpspell-dev \
        # for soap
        libxml2-dev \
        # for xsl
        libxslt1-dev \
        # for zip
        libzip-dev \
        # allow mailing to work
        sendmail \
        # allow reading of image exif
        exiftool \
        # allow unzipping
        unzip \
        # allow fetching
        wget \
    # pecl installs
    && docker-php-ext-install exif \
    && pecl install memcached \
    && pecl install redis \
    && pecl install apcu \
    # enable pecl installed extentions
    && docker-php-ext-enable memcached \
    && docker-php-ext-enable redis \
    && docker-php-ext-enable apcu \
    && docker-php-ext-enable exif \
    && docker-php-ext-enable opcache \
    # built in extensions install
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install -j$(nproc) \
        bcmath \
        bz2 \
        calendar \
        dba \
        gd \
        gettext \
        gmp \
        iconv \
        imap \
        intl \
        mbstring \
        mysqli \
        pdo \
        pdo_mysql \
        pcntl \
        pspell \
        soap \
        sockets \
        xsl \
        zip \
    # syslogd
    && apt-get install -y rsyslog \
    # cleanup
    && pecl clear-cache
COPY ./conf/php-fpm.conf /usr/local/etc/php-fpm.conf
COPY ./conf/00-php.ini /usr/local/etc/php/conf.d/00-php.ini
COPY ./conf/zzzz-override.ini /usr/local/etc/php/conf.d/zzzz-override.ini
COPY ./conf/docker-sendmail.ini /usr/local/etc/php/conf.d/docker-sendmail.ini

RUN mkdir -p /usr/share/man/man1

RUN apt update \ 
  && apt upgrade -y \
  && apt-get update \
  && apt-get install -y ssl-cert xfonts-utils fontconfig libxrender1 xfonts-75dpi xfonts-base libjpeg62-turbo libxext6 wget telnet redis-server default-jre git git-flow ssh

RUN usermod -u 501 www-data
RUN usermod -G staff www-data

RUN mkdir /root/.ssh/
RUN touch /root/.ssh/known_hosts
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts

COPY ./root/bash_profile /root/.bash_profile
COPY ./root/ssh/config /root/.ssh/config
COPY ./root/ssh/github.pkey /root/.ssh/github

#RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -
#RUN apt-get -y install nodejs
#RUN npm install

RUN rm -rf \
    /var/lib/apt/lists/* \
    /usr/src/php/ext/* \
    /tmp/*

RUN mkdir -p /shared/var/run/
RUN sed -i '/imklog/s/^/#/' /etc/rsyslog.conf
RUN touch /var/log/syslog

# https://hub.docker.com/_/composer/
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /root/.composer
ENV COMPOSER_VERSION 2

# https://github.com/wimg/PHPCompatibility/releases
ENV PHP_COMPATIBILITY_VERSION 8.1.0

RUN composer global require consolidation/robo
RUN composer global require friendsofphp/php-cs-fixer

COPY docker-entrypoint.sh /docker-entrypoint.sh

CMD ["/docker-entrypoint.sh"]
