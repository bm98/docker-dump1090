#!/bin/bash
#
# note: The default remote dump1090 is a dump1090 hosted on the google cloud. It may not be up and running.
# Set our own IP address of your dump1090 source here and build the docker image or 
# specify this /usr/share/dump1090-fa/startdump1090.sh script with the IP address/port of your dump1090 source while you launch the container.
#
# check for startup parameter(s)
if [ $# -gt 2 ] ; then
	echo "Too many parameters specified! Only an IP address and port (5 digits 3xxxx) are allowed!"
	exit 1;
fi
#
# Check if IP is valid:
if [ $# -gt 0 ] ; then
	if [[ $1 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
		ip=$1
	else 
		echo "IP address $1 is not valid!" | tee -a /var/log/dump1090-fa/errlog
		exit 2;
	fi
else 	
	# Default IP address of remote dump1090 source (currently my dump1090 instance):
	ip="192.168.1.82"
fi
#
# Check if Port is valid:
if [ $# -gt 1 ] ; then
	if [[ $2 =~ ^[0-3][0-9][0-9][0-9][0-9]$ ]]; then
		port=$2
	else 
		echo "IP port $2 is not valid!" | tee -a /var/log/dump1090-fa/errlog
		exit 2;
	fi
else 	
	# Default IP address of remote dump1090 source (currently my dump1090 instance outbound port):
	port="31005"
fi

# should be there already...
if [  ! -e /var/log/dump1090-fa ]; then
	mkdir -p /var/log/dump1090-fa
fi

#start HTTP server
service lighttpd start
#
# Start dump1090:
service dump1090-fa start

#
echo "Trying to get BEAST-format data from ${ip}:${port}}."
# Never ending loop in order to reconnect when the connection ever gets broken:
#while true
#do
	#
	# Check if IP address is reachable:
	if /bin/ping -c 1 $ip &> /dev/null ; then
		echo "IP address $ip is reachable using ping!"
	else
		echo "IP address $ip is unreachable using ping!" | tee -a /var/log/dump1090-fa/errlog
	fi
	#
	# Check if port 30005 is open (5 seconds timeout):
	echo "Remote port check:"
	/bin/nc -z -v -w5 $ip $port | tee -a /var/log/dump1090-fa/errlog
	#
	# Netstat info
	echo "Netstat:"
	/bin/netstat 
	#
	# copy BEAST-format traffic from a remote dump1090 (port 30005) to the container (port 30104).
	echo "nc $ip $port | nc localhost 30004" 
        /bin/nc  $ip $port | /bin/nc localhost 30004 2>> /var/log/dump1090-fa/errlog
	echo "Connection with ${ip}:${port} broken. Retry...."  | tee -a /var/log/dump1090-fa/errlog
	#
	# Wait 5 seconds before retry
        sleep 5
	# TODO would need to cut the errlog if this is going to fail always ...
#done
# for testing this will not loop forever but bail out 
# you may attach the container and review issues
echo "starting shell"
/bin/bash 
