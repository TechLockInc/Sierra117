#!/bin/bash

#Witten by Vu Mai
#This is a self-test script for TECH LOCK Penetration Testing Relay Virtual Appliance
#Purpose: Displaying some important network configuration to provide easier troubleshooting

exec_selftest() {
	#Declaring some network variables
	printf '\033[2J\033[;H'
	ip=`/sbin/ifconfig eth0 | grep "inet" | grep -v -e inet6 | awk '{print $2}'`
	netmask=`/sbin/ifconfig eth0 | grep "inet" | grep -v -e inet6 | awk '{print $4}'`
	gateway=`/sbin/ip route | awk '/default/ {print $3}'`
	tap=`/sbin/ifconfig tap0 | grep "inet" | grep -v -e inet6 | awk '{print $2}'`
	external=`grep "" /usr/local/bin/externalIP.txt | awk '{print $1}'`
	server=`grep domain /etc/openvpn/client.conf | awk '{print $2}'`
	port=`grep PublicIP /etc/openvpn/client.conf | awk '{print $3}'`
	publicIP=`grep PublicIP /etc/openvpn/client.conf | awk '{print $2}'`
	hostname=`grep "" /etc/hostname | awk '{print $1}'`

	#Greeting
	printf " ********************************************************\n"
	printf " * \e[32mTECH LOCK Incorporated - Penetration Testing Service\e[0m *\n"
 	printf " * \e[1m     Sierra117 Remote Testing Virtual Apppliance\e[0m     *\n"
	printf " ********************************************************\n"
	printf "\n"
	printf " \e[1mPlease contact your Security Consultant or Penetration Tester for any connection issue.\e[0m\n"
	printf "\n"

	#Displaying network information
	printf " Hostname          : \e[4m%s\e[0m\n" "$hostname"
	printf " Local IP Address  : \e[4m%s\e[0m\n" "$ip"
	printf " Local Subnet Mask : \e[4m%s\e[0m\n" "$netmask"
	printf " Local Gateway     : \e[4m%s\e[0m\n" "$gateway"
	printf " External IP       : \e[4m%s\e[0m\n" "$external"
	printf " Tunnel IP Address : \e[4m%s\e[0m\n" "$tap"
	printf "\n"
	printf "                  \e[1mPLEASE ENSURE THAT THE VIRTUAL MACHINE IS SET TO BRIDGED MODE!\e[21m\n"
	printf "\n"

	#Checking local network connection
	printf " \e[1mPinging the local gateway...\e[0m\n"
	if ping -q -c1 $gateway > /dev/null;
	then
		printf " \e[32mPASS\e[0m\n";
		printf "\n"

		#Checking OpenVPN connection
		printf " \e[1mConnecting to %s (%s) on port %s...\e[0m\n" "$server" "$publicIP" "$port";
		if ifconfig tap0 | grep -q RUNNING;
		then
			printf " \e[32mPASS\e[0m\n";
			printf "\n"
			printf " \e[1mVPN connection established...\e[0m\n";			
		
		else #If the VPN fails, display ERROR
			printf " \e[31mFAIL.\e[0m Please ensure that your network settings allow OpenVPN outbound traffic on port %s.\n" "$port";
		fi #End of checking OpenVPN connection
	
	else #If cannot ping the local gateway, display ERROR
		printf " \e[31mFAIL.\e[0m Cannot ping the local gateway. Is network information correct?\n";
	fi #End if checking local network connection

	printf "\n\n"
	printf " Refreshing every 10 seconds...\n"
}

openvpn --cd /etc/openvpn --config /etc/openvpn/client.conf >> /opt/VPN.log &
sysctl net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -j MASQUERADE
dig +short myip.opendns.com @resolver1.opendns.com > /usr/local/bin/externalIP.txt
while true; do
	sleep 10
	exec_selftest
done
