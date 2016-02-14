#Make a container based on latest debian
FROM debian:latest
MAINTAINER Jean-Baptiste WATENBERG <jbwatenberg@juniorisep.com>

#Install default packages

RUN echo mysql-server mysql-server/root_password password root | debconf-set-selections
RUN echo mysql-server mysql-server/root_password_again password root | debconf-set-selections
RUN apt-get -y update && apt-get install -y openssh-server apache2 php5 mysql-server libapache2-mod-php5 php5-mysql postgresql postgresql-contrib adminer
RUN apt-get -y install git

#required to install composer and get dependencies

RUN apt-get -y install curl php5-curl

#for debugging purposes

RUN apt-get -y install nano

#Install composer globaly

RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer

EXPOSE 80
	

#configure postgresql
USER postgres

RUN    /etc/init.d/postgresql start &&\
    psql --command "CREATE USER root WITH SUPERUSER PASSWORD 'root';"


USER root
