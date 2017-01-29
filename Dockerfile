FROM debian:jessie

MAINTAINER rp8 <rp8@competo.com>

ENV DEBIAN_FRONTEND noninteractive
ENV NGINX_VERSION 1.11.8-1~jessie

RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys E9C74FEEA2098A6E \
 && apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 \
 && echo "deb http://ftp.hosteurope.de/mirror/packages.dotdeb.org/ jessie all" >> /etc/apt/sources.list \
 && echo "deb http://nginx.org/packages/mainline/debian/ jessie nginx" >> /etc/apt/sources.list \
 && apt-get update \
 && apt-get install --no-install-recommends --no-install-suggests -y \
    ca-certificates \
		nginx=${NGINX_VERSION} \
		curl \
		pwgen \
		php7.0 \
		php7.0-common \
		php7.0-mysql \
		php7.0-fpm \
		php7.0-opcache \
		php7.0-gd \
		php7.0-curl \
		php7.0-mcrypt \
		php7.0-json \
		php7.0-tidy \
		php7.0-mbstring \
		php7.0-bz2 \
		php7.0-xml \
		php7.0-zip \
		php7.0-xmlrpc \
		php7.0-xsl \
 && rm -rf /var/lib/apt/lists/*

ENV WORDPRESS_VERSION 4.7.1
ENV WORDPRESS_SHA1 8e56ba56c10a3f245c616b13e46bd996f63793d6

RUN { \
	echo 'opcache.memory_consumption=128'; \
	echo 'opcache.interned_strings_buffer=8'; \
	echo 'opcache.max_accelerated_files=4000'; \
	echo 'opcache.revalidate_freq=2'; \
	echo 'opcache.fast_shutdown=1'; \
	echo 'opcache.enable_cli=1'; \
    } > /etc/php/7.0/fpm/conf.d/opcache-recommended.ini \
&& curl -o wordpress.tar.gz -fSL "https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz" \
&& echo "$WORDPRESS_SHA1 *wordpress.tar.gz" | sha1sum -c - \
&& tar -xzf wordpress.tar.gz -C /usr/share/nginx/; rm wordpress.tar.gz \
&& chown -R www-data:www-data /usr/share/nginx/wordpress \
&& sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf \
&& sed -i -e"s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 100m/" /etc/nginx/nginx.conf \
&& echo "daemon off;" >> /etc/nginx/nginx.conf \
&& sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php/7.0/fpm/php.ini \
&& sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" /etc/php/7.0/fpm/php.ini \
&& sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" /etc/php/7.0/fpm/php.ini \
&& sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.0/fpm/php-fpm.conf \
&& sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php/7.0/fpm/pool.d/www.conf \
&& sed -i -e "s/^listen.*/listen = 127.0.0.1:9000/" /etc/php/7.0/fpm/pool.d/www.conf \
&& find /etc/php/7.0/cli/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;

ADD ./start.sh /start.sh

RUN chmod 755 /start.sh

EXPOSE 80 443

VOLUME /etc/nginx/conf.d
VOLUME /var/www

CMD ["/bin/bash", "/start.sh"]
