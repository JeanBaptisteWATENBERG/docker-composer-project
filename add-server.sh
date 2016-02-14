#!/bin/sh
echo -n "Git repository URL :"
read gitrepository
repositoryname=`echo "$gitrepository" | cut -d'/' -f5 | cut -d'.' -f1`
echo -n "\n Looking for an available port \n"
httpport=`netstat -atn | awk ' /tcp/ {printf("%s\n",substr($4,index($4,":")+1,length($4) )) }' | sed -e "s/://g" | sort -rnu | awk '{array [$1] = $1} END {i=32768; again=1; while (again == 1) {if (array[i] == i) {i=i+1} else {print i; again=0}}}'`
echo -n "Choosen port $httpport \n"
echo -n "\n Running container \n"
container=`docker run --name docker-composer-project-$repositoryname -d -p $httpport:80 docker-composer-project /usr/sbin/apache2ctl -D FOREGROUND`
echo -n "Container id : $container"
echo -n "\n Container configuration \n"
#allow the execution of nano
docker exec -i $container bash -c "export TERM=xterm"
#clone the repository and install the dependancies
echo -n "\n Clonning $repositoryname... \n"
docker exec -i $container bash -c "cd /var/www/html && git clone $gitrepository && cd $repositoryname && composer install"
#fix writing rights
echo -n "\n Give full rights for debugging purpses only... \n"
docker exec -i $container bash -c "cd /var/www/html/$repositoryname && chmod -R 777 ."
#fix timezone issues
echo -n "\n Configure PHP (timezone)... \n"
docker exec -i $container bash -c "sed -i 's/\;date\.timezone\ \=/date\.timezone\ \=\ Europe\/Paris/g' /etc/php5/cli/php.ini && \
	sed -i 's/\;date\.timezone\ \=/date\.timezone\ \=\ Europe\/Paris/g' /etc/php5/apache2/php.ini"

#configuring apache
docker exec -i $container bash -c "a2dissite 000-default.conf"
docker exec -i $container bash -c "echo -e \"<VirtualHost *:80> \\n \
	ServerAdmin sysadmin@juniorisep.com \\n \
	DocumentRoot /var/www/html/$repositoryname \\n \
	<Directory /var/www/html/$repositoryname> \\n \
                Options Indexes FollowSymLinks MultiViews \\n \
                AllowOverride All \\n \
                Order allow,deny \\n \
                allow from all \\n \
    </Directory> \\n \
 \\n \
	ErrorLog \${APACHE_LOG_DIR}/error.log \\n \
	CustomLog \${APACHE_LOG_DIR}/access.log combined \\n \
</VirtualHost>\" > /etc/apache2/sites-available/000-default.conf"
docker exec -i $container bash -c "a2ensite 000-default.conf"
docker exec -i $container bash -c "service apache2 reload"

echo -n "\n Container sucessfully created ! \n"
containerIp=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' $container`
echo -n "Available at : http://127.0.0.1:$httpport or http://$containerIp \n \n"

