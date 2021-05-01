FROM debian:buster
MAINTAINER jikang <jikang@student.42seoul.kr>

# UPDATE
RUN apt-get update

# INSTALL
RUN apt-get -y install nginx
RUN apt-get -y install vim
RUN apt-get -y install wget
RUN apt-get -y install mariadb-server
RUN apt-get -y install php7.3 php-mysql php-fpm php-cli php-mbstring

# INSTALL PHPMYADMIN in /usr/share
WORKDIR /usr/share/
RUN wget https://files.phpmyadmin.net/phpMyAdmin/4.9.1/phpMyAdmin-4.9.1-english.tar.gz
RUN tar xf phpMyAdmin-4.9.1-english.tar.gz && rm -rf phpMyAdmin-4.9.1-english.tar.gz
RUN mv phpMyAdmin-4.9.1-english phpmyadmin
COPY ./srcs/config.inc.php /usr/share/phpmyadmin/config.inc.php
RUN mkdir -p /var/lib/phpmyadmin/tmp
RUN chown -R www-data:www-data /var/lib/phpmyadmin
RUN chmod -R 755 /var/lib/phpmyadmin
# tmp에는 모든 권한 주기
RUN chmod 777 /var/lib/phpmyadmin/tmp

# ln -s from /usr/share to /var/www
RUN ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin

# INSTALL WORDPRESS in /usr/share
WORKDIR /usr/share/
RUN wget -c https://wordpress.org/latest.tar.gz
RUN tar xf latest.tar.gz && rm -rf latest.tar.gz
COPY ./srcs/wp-config.php /usr/share/wordpress/wp-config.php
RUN chown -R www-data:www-data /usr/share/wordpress
RUN chmod 755 -R wordpress
RUN mkdir /usr/share/wordpress/wp-content/upgrade
RUN mkdir /usr/share/wordpress/wp-content/uploads
RUN mkdir /usr/share/wordpress/wp-content/temp

# SYMLINK from /usr/share to /var/www/html
RUN ln -s /usr/share/wordpress /var/www/html/wordpress

# SSL KEY GENERATE
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -subj '/C=KR/O=42Seoul' -keyout /etc/ssl/private/localhost.dev.key -out /etc/ssl/certs/localhost.dev.crt

# WWW-DATA AUTHORIZATION rwe, re, re
WORKDIR /
RUN chown -R www-data:www-data var/www/*
RUN chmod -R 755 var/www/*
COPY ./srcs/nginx_config /etc/nginx/sites-available/default
COPY ./srcs/phpinfo.php /var/www/html/phpinfo.php
COPY ./srcs/mysql_setup.sql /tmp/mysql_setup.sql

# SERVICE START
COPY ./srcs/service_start.sh ./tmp/service_start.sh
CMD bash ./tmp/service_start.sh