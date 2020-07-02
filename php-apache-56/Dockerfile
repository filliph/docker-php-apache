FROM php:5.6.39-apache-stretch

RUN apt-get update && apt-get install -y ssl-cert && rm -rf /var/lib/apt/lists/*

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/ssl-cert-snakeoil.key -out /etc/ssl/certs/ssl-cert-snakeoil.pem -subj "/C=AT/ST=Vienna/L=Vienna/O=Security/OU=Development/CN=example.com"

RUN a2enmod rewrite
RUN a2ensite default-ssl
RUN a2enmod ssl

ARG DOCKER_PHP_EXT_INSTALL
ARG DOCKER_PHP_PECL_INSTALL

# https://hub.docker.com/_/composer/
COPY --from=composer:1.6.5 /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /tmp
ENV COMPOSER_VERSION 1.6.5

# https://github.com/wimg/PHPCompatibility/releases
ENV PHP_COMPATIBILITY_VERSION 8.1.0

RUN usermod -u 501 www-data
RUN usermod -G staff www-data

COPY override.ini /usr/local/etc/php/conf.d/

COPY bash_profile /root/.bash_profile

COPY . /tmp/.
RUN /tmp/build.sh

RUN wget http://robo.li/robo.phar \
  && chmod +x robo.phar \ 
  && mv robo.phar /usr/local/bin/robo