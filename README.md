# Acknowledgment

Thanks to Ted Sluis for the great idea and work I could start from..
https://github.com/tedsluis  


# Docker image for Dump1090-Mutability

This is a fork of [docker-dump1090](https://github.com/tedsluis/docker-dump1090)
to create a docker image from [dump1090-fa](https://github.com/bm98/dump1090)
Try the dump1090 application in an easy way and run it in a Docker container.  
No RTL-SDR receiver is required or supported.  

You have two options:

* Run it on a X86_64 or AMD64 Linux [Docker](https://docs.docker.com/linux) host (Intel or AMD hardware). 
* Run it on a Raspberry pi with raspbian and [Hypriot Docker](http://blog.hypriot.com/downloads/) (ARM hardware).

While running this dump1090 docker container you are able to view airplanes in your web browser.   
You can always rebuild it in minutes from the latest source code (on a raspberry pi that is already running dump1090 and piaware it takes about a hour!).  
Downloading the latest docker image from Docker hub takes a few minutes.  

These docker images are based on a modified dump1090-fa v3.6.2 by the FlightAware team:

* [dump1090-fa](https://github.com/bm98/dump1090) (version v3.6.2.1)

These builds are based on the stable  [Debian Docker image (for X86_64,AMD64)](https://hub.docker.com/_/debian/)
Some packages were added, because they are not default available in the Docker bases images. 
The way in which the Lighttpd and Dump1090 services are started is slightly different as is usual with containers. 
The configuration is of course without user interaction.
External configuration sources are supported.

# Docker Hub

Not yet available...

# Usage

### docker command and sudo 
In all the examples down here I have not used the 'sudo' command. Depending on the way you have implementated Docker (or Hypriot Docker) you may need to use 'sudo' in front every 'docker' command. For example:  
````
$ sudo docker version
or 
$ sudo docker stats $(sudo docker ps -a -q)
````
Otherwise you may get an error message telling that it cannot connect to the docker daemon!  

### Download the dockerfile
This step is optional: If you don't build the image your self it will be downloaded the first time you try to run it. In this case skip the sections 'Download the dockerfile', 'Tweak the dockerfile' and 'Build the docker image' continue at ['Run a docker container:'](https://github.com/tedsluis/docker-dump1090#run-a-docker-container).  
 
Download the dockerfile:  
````
$ wget https://raw.githubusercontent.com/bm98/docker-dump1090/master/dockerfile  
````
### Tweak the dockerfile
Optional: At this stage you may want to edit the dockerfile and change for example:

* the URL of your own config files.
* your own ADS-B BEAST source IP address.

notes:   
Check the comments inside the dockerfiles for more info.

### Build the docker image
Build the image (select the version you want, X86/AMD64 or ARM, with or without heatmap & rangview):
````
$ docker build -t bm98/dump1090-fa:v3.6.2.1 .
````
### Run a docker container
Run it:

````
$ docker run -d -h dump1090-fa -p 9090:8080 bm98/dump1090-fa:v3.6.2.1
````

You can run more then a single dump1090 container, but be sure that you use a different 'host name' (-h &lt;host name&gt;) and 'outside port number' (-p &lt;outside port:inside port&gt;) for every container!  

### Run a docker container with an alternative remote source
You can changes the setting remote ADS-B BEAST input source in the startdump1090.sh or in the dockerfile and rebuild the docker image. It is easier (and your only option if you don't build the Docker image your self) to specify your own remote BEAST source dump1090 IP address and port like this (this can be any dump1090 with a RTL-SDR receiver).   

````
$ docker run -d -h dump1090-fa -p 9090:8080 bm98/dump1090-fa:v3.6.2.1 /usr/share/dump1090-fa/startdump1090.sh "IP" "Port"
  where IP is the IP address of your source  [aaa.bbb.ccc.ddd notation]
  and Port is the source port as 5 digits e.g.  30005 [10000..39999 allowed]
````

### Try dump1090 in the browser
To use the GUI, go to your browser and type:
http://IPADDRESS_DOCKERHOST:9090  
You may need to refresh your web browser a view times before you seen planes.
Running on a raspberry pi it can take a while.   

### Manage the containers

Check the resource consumption per docker container and notice that it is very low compared to a VM or a raspberry:
````
$ docker stats $(docker ps -a -q)
````
Only the dump1090, the lighttp web server and the netcat (nc) services are running:
````
docker top <container_id>
````

View the container log
````
docker logs <container_id>
````

To stop a container, use:
````
docker stop <container_id>
````

Or stop all your containers all at ones:
````
docker stop $(docker ps -a -q)
````

Or kill them all at ones (much faster):
````
docker kill $(docker ps -a -q)
````

Start a docker container again:
```` 
docker start <container_id>
````

Start all your containers all at ones:
````
docker start $(docker ps -a -q)
````

Remove the containers all at ones:
````
docker rm $(docker ps -a -q)
````

# Notes

These dockerfiles will override the default dump1090 config files:

* /usr/share/dump1090-fa/html/config.js     (not yet supported)
* /etc/default/dump1090-fa                  (not yet supported)

This way my personal settings like lat/lon etc. 

Of course you should modify the dockerfile and configure the location of your own config files and your own remote BEAST IP address.  

# 30005 Data source

This dump1090 doesn't collect ADS-B data using an antenna and a RTL SDR receiver.   
Instead it receives data using the BEAST_INPUT_PORT (30004).  

In side the container I use netcat to copy 31005 traffic from an remote dump1090 to the local 30004 BEAST input port.  




