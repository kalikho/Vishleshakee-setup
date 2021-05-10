# Dockerfile
# for vishleshakee website (bhogdoi.iitg.ac.in)
# Rajib Chakrabartty <rajibc[at]iitg[dot]ac[dot]in>
#
# v1: 20210421
# v2: 20210506

# use centos 7 as the base image
from centos:7

# flame target
label maintainer="Rajib Chakrabartty <rajibc[at]iitg[dot]ac[dot]in>"	\
		organization="IIT Guwahati" \
		department="CSE" \
		section="OSINT Lab"

# update the system,  and install the core required packages from the official
# system repos
run	yum update -y \
	&& yum install  git unzip openssl httpd mod_ssl -y

# the vishleshakee requires:
#  a. php v7.2
#  b. mariadb v10
#  c. php-cassandra driver
#  d. laravel, and
#  e. the app code, of course
#
# none of the above requirements are natively available in the official centos
# repos.  as such, we need to use third party repos for them.  app code is
# availabel in git
#
# (a,c) install php v7.2, php-cassandra driver, and the related required
# packages.  we are using the `remi' repository.  `epel' repo is a requirement
# of `remi'
run	yum install  epel-release -y \
	&& yum install  https://rpms.remirepo.net/enterprise/remi-release-7.rpm -y \
	&& yum-config-manager  --enable remi-php72 \
	&& yum install  php php-bcmath php-mbstring php-pdo php-xml php-mysqlnd \
		libuv cassandra-cpp-driver php-pecl-cassandra -y

# (b) install mariadb v10.  we are using the official MariaDB repo
copy	files/MariaDB.repo  /etc/yum.repos.d/
run	yum install  MariaDB-server MariaDB-client -y

# this completes the  instalattion  of packages from the repos.  clear the yum
# cache and related files to free-up space
run	yum clean all

# (d,e) pull the app code from git, and install laravel
#
# install php composer tool
run	curl https://getcomposer.org/download/2.0.12/composer.phar -o /usr/local/bin/composer \
	&& chmod 744 /usr/local/bin/composer
# pull the  app code into  `vishleshakee'  dir,  and set  proper ownership and
# permissions
workdir  /var/www/html
run	git clone https://github.com/Blade365z/vishleshakee.git \
	&& chown -R root:apache vishleshakee/ \
	&& find ./vishleshakee -type d -exec chmod 750 {} \; \
	&& find ./vishleshakee -type f -exec chmod 640 {} \; \
	&& chown -R apache:root vishleshakee/storage/ \
	&& chown -R apache:root vishleshakee/bootstrap/cache/
# enable .htaccess in vishleshakee
copy	files/vishleshakee.conf  /etc/httpd/conf.d/

# setup laravel
workdir  /var/www/html/vishleshakee
run	cp  .env.example .env \
	&& chown root:apache .env \
	&& chmod 640 .env \
	&& composer install \
	&& php artisan config:clear \
	&& php artisan cache:clear \
	&& php artisan key:generate

# advertise the web server ports (not strictly needed)
expose 80/tcp
expose 443/tcp
# /tcp is optional -- default is tcp

# use a helper script to setup the database on the first run, and start the
# web and database server
workdir  /
copy  files/startup.sh .
run	chmod +x startup.sh \
	&& touch __FIRST_RUN__
entrypoint ["/startup.sh"]

# should do

# changelog:
# v2:
#   - instead of using a prepared .env file, use the example .env file
#     provided by laravel, and later on in the startup scipt change the
#     required settings by sed

