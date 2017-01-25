#!/bin/bash
WPCONFIG=/usr/share/nginx/wordpress/wp-config.php
if [ ! -f /usr/share/nginx/wordpress/wp-config.php ]; then
  if [ "$MYSQL_DB" != "wordpress" ]; then
    WPCONFIG=/var/www/$MYSQL_DB/wp-config.php
    if [ ! -f /var/www/$MYSQL_DB ]; then
    	cp -R /usr/share/nginx/wordpress /var/www
    	chown -R www-data:www-data /var/www/wordpress
    	mv /var/www/wordpress /var/www/$MYSQL_DB
    fi
  fi
  
  sed -e "s/database_name_here/$MYSQL_DB/
  s/username_here/$MYSQL_USER/
  s/password_here/$MYSQL_PASSWORD/
  s/localhost/$MYSQL_PORT_3306_TCP_ADDR/
  /'AUTH_KEY'/s/put your unique phrase here/`pwgen -c -n -1 65`/
  /'SECURE_AUTH_KEY'/s/put your unique phrase here/`pwgen -c -n -1 65`/
  /'LOGGED_IN_KEY'/s/put your unique phrase here/`pwgen -c -n -1 65`/
  /'NONCE_KEY'/s/put your unique phrase here/`pwgen -c -n -1 65`/
  /'AUTH_SALT'/s/put your unique phrase here/`pwgen -c -n -1 65`/
  /'SECURE_AUTH_SALT'/s/put your unique phrase here/`pwgen -c -n -1 65`/
  /'LOGGED_IN_SALT'/s/put your unique phrase here/`pwgen -c -n -1 65`/
  /'NONCE_SALT'/s/put your unique phrase here/`pwgen -c -n -1 65`/" \
  /usr/share/nginx/wordpress/wp-config-sample.php > $WPCONFIG

  chown www-data:www-data $WPCONFIG
fi

/etc/init.d/php7.0-fpm start
/etc/init.d/nginx start
