service mysql start

mysql -u root mysql < /tmp/mysql_setup.sql

service php7.3-fpm start
service nginx start

bash