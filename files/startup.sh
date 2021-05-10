#!/bin/bash
#
# start the web and database servers, and run the first run tasks if required
# Rajib Chakrabartty <rajibc[at]iitg[dot]ac[dot]in>
#
# v1: 20210420
# v2: 20210505

# fail if any of the pipe component fails
#set -o pipefail

# exit if any error occurs
set -o errexit	# or: set -e

# first of all, check if running for the first time
if [ -f /__FIRST_RUN__ ]; then
	echo "Executing first run tasks..."
	echo

	#1 mariadb setup
	echo "1/3 : Setting up database objects"
	# start mariadb server in the background
	mariadbd-safe &
	sleep 3s
	# create the required `smat' database
	mariadb -u root --execute="create database smat;"
	# import the required tables and data
	#mariadb -u root --database=smat < /var/www/html/vishleshakee/dumps/smat.sql
	mariadb -u root --database=smat < /var/www/html/vishleshakee/dumps/smat-2021-April-19.sql
	# insert required row for laravel authentication
	mariadb -u root --database=smat --execute="insert into users values (0,'admin','iitg',1,'\$2y\$10\$oHrlES8i97H5fcCj29xeHeUB14kvAI1f0laFehyqggtgTqQDTBLf.',NULL,'2021-04-25 15:07:10','2021-04-25 15:07:10');"
	# add mariadb user, and grant privilege for 'smat' db
	mariadb -u root --execute="create user 'admin'@'localhost' identified by 'abc123';"
	mariadb -u root --execute="grant all on smat.* to 'admin'@'localhost';"
	# reload privileges
	mariadb-admin -u root reload

	#2 modify laravel .env parameters
	echo "2/3 : Setting up Laravel options"
	host_ip_address=$(hostname -i | expand | tr -s ' ' | cut -d' ' -f1)
	sed -i -e 's/^APP_NAME=Laravel/APP_NAME=Vishleshakee/' \
		 -e 's/^DB_DATABASE=laravel/DB_DATABASE=smat/' \
		 -e 's/^DB_USERNAME=root/DB_USERNAME=admin/' \
		 -e 's/^DB_PASSWORD=/DB_PASSWORD=abc123/' \
		 -e "s/^APP_URL=http:\/\/localhost/APP_URL=http:\/\/${host_ip_address}\/vishleshakee\//" \
		 /var/www/html/vishleshakee/.env
	# run laravel migrate to create the required tables
	#cd /var/www/html/vishleshakee/
	#php artisan migrate
	
	# delete first run file on successful setup
	rm -f /__FIRST_RUN__

	#3 start the web server
	echo "3/3: Staring Web Server"
	apachectl -k start -DFOREGROUND
else
	# not first run.  start the web and the database servers
	apachectl -k start
	mariadbd-safe
fi

# should do

# changelog
# v2:
#   - using a standard file-name (smat.sql) for 'smat' database structure and
#     data import (first run)
#   - inserted a predefined row into the laravel 'users' table (first run)
#   - created the 'admin' user, and granted all privileges to the 'smat' db
#     objects to the user.  also reload the grant tables (first run)
#   - modified the required parameters of the laravel .env file at first run
#     instead of using a prepared .env file
#   - run laravel migrate command to generate the required tables

