# docker-wordpress-nginx

Wordpress with PHP 7.0, PHP7.0-FPM & NGINX (1.11) on Debian Jessie

Original work from @eugeneware/docker-wordpress-nginx.

## Build Image
```bash
$ git clone https://github.com/rp8/docker-wordpress-nginx.git
$ cd docker-wordpress-nginx
$ sudo docker build -t="wordpress" .
```

## MySQL

```bash
$ sudo docker pull mysql:5.7
$ sudo docker run --name mysqldb -e MYSQL_ROOT_PASSWORD=secrets -d mysql:5.7
...
$ sudo docker exec mysqldb sh -c 'exec mysqldump -all-databases uroot -psecrets' > dump.sql
...
$ sudo docker exec -i mysqldb mysql -uroot -psecrets --force < ./dump.sql
```

Create a database "wordpress" and new user "wordpress":
```bash
$ sudo docker exec -it mysqldb bash
# mysql -u root -p
mysql>Create database wordpress; GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'%' IDENTIFIED BY 'secrets'; FLUSH PRIVILEGES;
```

## Wordpress
The file nginx-sites.conf contains site configuration and should be copied to the container volume /etc/nginx/conf.d. If you host multiple sites, 
each site needs its own folder in /var/www and its own database in the container mysqldb.

For single site configuration, you can config the nginx to point the root directly to the nginx default folder /usr/share/nginx/wordpress.

For multi-site configuration, you can use the following commands to create another copy of wordpess in /var/www or you can just log into the wordpress container and run the following commands
```bash
cp -R /usr/share/nginx/wordpress /var/www/; mv /var/www/wordpress /var/www/xxx; chown www-data:www-data /var/www/xxx
```

For additional sites, you can make copyies directly in /home/www in the host directly without logging into the wordpress container.

```bash
$ cp nginx-sites.conf /home/nginx/
$ sudo docker run -p 80:80 --name wordpress -v /home/www:/var/www -v /home/nginx:/etc/nginx/conf.d -e MYSQL_USER=wordpress \
  -e MYSQL_PASSWORD=secrets -e MYSQL_DB=wordpress --link mysqldb:mysql -d wordpress
...
$ sudo docker start wordpress
...
$ sudo docker stop wordpress
...
$ sudo docker ps -a
```

## Check from Browser
```
http://localhost/readme.html
```
