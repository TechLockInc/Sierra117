#!/bin/bash

echo "Please enter client code:"
read CC

echo "Please enter agent's tunnel IP:"
read gw

mkdir /root/$CC

for subnet in $(cat /root/$CC.txt); do
	ip route add $subnet via $gw;
	net=`echo $subnet | cut -d"/" -f1`;
	mkdir /root/$CC/$net;
	cd /root/$CC/$net;
	python /opt/PingSweep/ping_sweep.py $subnet > LiveHosts;
	echo "Please review the ping sweep result!";
	gedit LiveHosts;
done

for subnet in $(cat /root/$CC.txt); do
	echo "Scanning the subnet $subnet ..."
	echo
	net=`echo $subnet | cut -d"/" -f1`;
	cd /root/$CC/$net;
	for ip in $(cat LiveHosts); do
		echo "Scanning $ip...";
		nmap -A -Pn $ip > $ip.txt;
		echo "...done!";
		echo;
	done
done
