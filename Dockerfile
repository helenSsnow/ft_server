FROM debian:buster

EXPOSE 80 443

#обновляем нашу систему, чтобы все успешно установилось
RUN apt-get update -y
RUN apt-get upgrade -y
#чтобы мы могли использовать эту команду при скачивании
RUN apt-get install -y wget
RUN apt-get install -y vim
RUN apt-get install -y nginx
RUN apt-get -y install openssl
#необходим если у нас нет сервера mysql
RUN apt-get -y install mariadb-server
ADD /srcs/database.sql /tmp/
#Для phpmyadmin
RUN apt-get -y install php7.3-fpm php7.3-common php7.3-mysql php7.3-gmp php7.3-curl php7.3-intl php7.3-mbstring php7.3-xmlrpc php7.3-gd php7.3-xml php7.3-cli php7.3-zip php7.3-soap php7.3-imap
RUN mkdir /var/www/html/phpmyadmin
RUN wget https://files.phpmyadmin.net/phpMyAdmin/4.9.0.1/phpMyAdmin-4.9.0.1-all-languages.tar.gz
RUN tar -xvf phpMyAdmin-4.9.0.1-all-languages.tar.gz --strip-components 1 -C /var/www/html/phpmyadmin  
COPY /srcs/config.inc.php /var/www/html/phpmyadmin/config.inc.php
#Для вордпресса
RUN mkdir /var/www/html/wordpress
RUN wget https://ru.wordpress.org/latest-ru_RU.tar.gz
RUN tar -xvf latest-ru_RU.tar.gz && mv wordpress /var/www/html
RUN rm -rf latest-ru_RU.tar.gz
ADD /srcs/wp-config.php /var/www/html/wordpress/wp-config.php 
RUN service mysql start && mysql -u root --password= < /tmp/database.sql 
#Меняем файлдля nginx
COPY /srcs/default ./etc/nginx/sites-available/default

#Создаем самоподписанный сертификат
#Для того чтобы не вводить в интерактивном режиме данные о себе C=страна, ST-штат L-город O-имя организации CN- имя по которому к серверу будут обращаться
RUN openssl req -x509 -nodes -newkey rsa:2048 -days 365 -keyout /etc/ssl/private/localhost.key -out /etc/ssl/certs/localhost.crt -subj "/C=RU/ST=MOSCOW/L=MOSCOW/O=ssnowbir/CN=localhost"

RUN chown -R www-data:www-data /var/www/html/*
RUN chmod -R 755 /var/www/html/*

CMD	 service nginx start;\
	service mysql start;\	    
	 service php7.3-fpm start;\
	 bash
     
