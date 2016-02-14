#!/bin/sh
echo -n "Path of the zip file  :"
read gitrepository
repositoryname=`echo "$gitrepository" | rev |cut -d'/' -f1 | rev | cut -d'.' -f1`
echo -n "\n Looking for an available port... \n"
httpport=`netstat -atn | awk ' /tcp/ {printf("%s\n",substr($4,index($4,":")+1,length($4) )) }' | sed -e "s/://g" | sort -rnu | awk '{array [$1] = $1} END {i=32768; again=1; while (again == 1) {if (array[i] == i) {i=i+1} else {print i; again=0}}}'`
echo -n "Choosen port $httpport \n"
echo -n "\n Running container \n"
echo -n "\n Unzip $repositoryname... \n"
currentPath=`pwd`
mkdir -p volumes
unzip $gitrepository -d volumes
container=`docker run --name docker-composer-project-$repositoryname -d -p $httpport:80 -v $currentPath/volumes/$repositoryname:/var/www/html/$repositoryname docker-composer-project /usr/sbin/apache2ctl -D FOREGROUND`
containerIp=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' $container`
echo -n "Container id : $container"
echo -n "\n Configuring container... \n"
#allow the execution of nano
docker exec -i $container bash -c "export TERM=xterm"
#clone the repository and install the dependancies
docker exec -i $container bash -c "cd /var/www/html && cd $repositoryname && composer install"
#fix writing rights
echo -n "\n Give full rights for debugging purposes... \n"
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

echo -n "\n The container has been successfully created ! \n"
echo -n "Available at : http://127.0.0.1:$httpport or http://$containerIp \n \n"


