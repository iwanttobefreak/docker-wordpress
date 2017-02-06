FROM debian:jessie

RUN apt-get update \
 && apt-get install -y apt-utils wget

RUN  export DEBIAN_FRONTEND=noninteractive \
 && echo 'mysql-server mysql-server/root_password password dadada01' | debconf-set-selections \
 && echo 'mysql-server mysql-server/root_password_again password dadada01' | debconf-set-selections \
 && apt-get install -y mysql-server apache2 libapache2-mod-php5 php5-mysql

COPY install/create_database.sql /root/install/create_database.sql
RUN cd /var/www && rm -rf html && wget --no-check-certificate https://wordpress.org/wordpress-4.7.2.tar.gz && tar -xzvf wordpress-4.7.2.tar.gz && mv wordpress html

RUN /etc/init.d/mysql start \
 && mysql -u root "-pdadada01" < /root/install/create_database.sql

RUN cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php \
 && sed -i 's/database_name_here/wordpress/g' /var/www/html/wp-config.php \
 && sed -i 's/username_here/wordpress/g' /var/www/html/wp-config.php \
 && sed -i 's/password_here/wordpress01/g' /var/www/html/wp-config.php \
 && chown -R www-data. /var/www/html

CMD /etc/init.d/apache2 start \
 && /etc/init.d/mysql start \
 && /bin/bash
