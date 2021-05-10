# The file contains a installation wizard to deploy vishleshakee's Web environment.

## Building the Vishleshakee environment

To build the docker file use the command:
docker build -t local/vishleshakee:v2 . | tee /tmp/build.out

To disable cache use
docker build --no-cache --pull -t local/vishleshakee:v2 . | tee /tmp/build.out

## Running the container

Once the build is over, To run the container use the command:
docker run --name vishleshakee --hostname vishleshakee.iitg.ac.in local/vishleshakee:v2

## The container is CentOS 7 based container along with the following dependencies

Some core dependencies like:

1. OpenSSL
2. Httpd
3. mod_ssl
4. libuv
5. cassandra-cpp-driver

| Dependency    | Versiom |
| ------------- | ------- |
| PHP           | 7.2     |
| MariaDB       | 10      |
| PHP-Cassandra | 1.3     |
| Composer      | 2.0.12  |
| Laravel       | 7.0     |

Note:: PHP has been installed through remi repository.

## After build

Open the application thorugh your browser

### To setup the database credentials & hosts:

1. Login to the system
2. Go to More on the right side of the Nav bar, click on Configure
3. Go to Cofigure Environment
4. Setup up the hosts and the credentials
5. Click on Save
