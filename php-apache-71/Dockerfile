FROM php:7.1.33-apache-stretch

RUN mkdir -p /usr/share/man/man1

RUN apt update \ 
  && apt upgrade -y \
  && apt-get update \
  && apt-get install -y ssl-cert xfonts-utils fontconfig libxrender1 xfonts-75dpi xfonts-base libjpeg62-turbo libxext6 wget telnet redis-server default-jre git git-flow ssh

RUN mkdir /root/.ssh/
RUN touch /root/.ssh/known_hosts
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts

RUN wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.stretch_amd64.deb \
  && dpkg -i wkhtmltox_0.12.5-1.stretch_amd64.deb

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get -y install nodejs
RUN npm install

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/ssl-cert-snakeoil.key -out /etc/ssl/certs/ssl-cert-snakeoil.pem -subj "/C=AT/ST=Vienna/L=Vienna/O=Security/OU=Development/CN=example.com"

RUN a2enmod rewrite
RUN a2ensite default-ssl
RUN a2enmod ssl

ARG DOCKER_PHP_EXT_INSTALL
ARG DOCKER_PHP_PECL_INSTALL

# https://hub.docker.com/_/composer/
COPY --from=composer:1.10.9 /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /root/.composer
ENV COMPOSER_VERSION 1.10.9

# https://github.com/wimg/PHPCompatibility/releases
ENV PHP_COMPATIBILITY_VERSION 8.1.0

RUN usermod -u 501 www-data
RUN usermod -G staff www-data

COPY override.ini /usr/local/etc/php/conf.d/

COPY bash_profile /root/.bash_profile
COPY config /root/.ssh/config

COPY . /tmp/.
RUN /tmp/build.sh

RUN composer global require friendsofphp/php-cs-fixer

RUN wget http://robo.li/robo.phar \
  && chmod +x robo.phar \ 
  && mv robo.phar /usr/local/bin/robo