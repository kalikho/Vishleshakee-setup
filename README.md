# The file contains a installation wizard to deploy vishleshakee's Web environment.



## Building the Vishleshakee environment

To build the docker file use the command:
docker build  -t local/vishleshakee:v2 . | tee /tmp/build.out

To disable cache use 
docker build --no-cache --pull -t local/vishleshakee:v2 . | tee /tmp/build.out


## Running the container

Once the build is over, To run the container use the command: 
docker run --name vishleshakee --hostname vishleshakee.iitg.ac.in local/vishleshakee:v2
