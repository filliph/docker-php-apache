FROM mariadb:10.5

COPY etc/mysql/my.cnf /etc/mysql/my.cnf

RUN usermod -u 501 mysql
RUN usermod -G staff mysql