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

	#Greeting
	echo "********************************************************"
	echo -e "* \e[32mTECH LOCK Incorporated - Penetration Testing Service\e[0m *"
 	echo -e "* \e[1m     Sierra117 Remote Testing Virtual Apppliance\e[0m     *"
	echo "********************************************************"
	echo
	echo -e "\e[1mPlease contact your Security Consultant or Penetration Tester for any connection issue.\e[0m"
	echo

	#Displaying network information
	echo -e Local IP Address: "\e[4m$ip\e[0m"
	echo -e Local Subnet Mask: "\e[4m$netmask\e[0m"
	echo -e Local Gateway: "\e[4m$gateway\e[0m"
	echo -e External IP: "\e[4m$external\e[0m"
	echo -e Tunnel IP Address: "\e[4m$tap\e[0m"
	echo
	echo -e "                  \e[1mPLEASE ENSURE THAT THE VIRTUAL MACHINE IS SET TO BRIDGED MODE!\e[21m"
	echo

	#Checking local network connection
	echo -e "\e[1mPinging the local gateway...\e[0m"
	if ping -q -c1 $gateway > /dev/null;
	then
		echo -e "\e[32mPASS\e[0m";
		echo

		#Checking OpenVPN connection
		echo -e "\e[1mConnecting to $server ($publicIP) on port $port...\e[0m";
		if ifconfig tap0 | grep -q RUNNING;
		then
			echo -e "\e[32mPASS\e[0m";
			echo
			echo -e "\e[1mVPN connection established...\e[0m";			
		
		else #If the VPN fails, display ERROR
			echo -e "\e[31mFAIL.\e[0m Please ensure that your network settings allow OpenVPN outbound traffic on port $port.";
		fi #End of checking OpenVPN connection
	
	else #If cannot ping the local gateway, display ERROR
		echo -e "\e[31mFAIL.\e[0m Cannot ping the local gateway. Is network information correct?";
	fi #End if checking local network connection

	echo
	echo
	echo "Refreshing every 10 seconds..."
}

curl ipecho.net/plain > /usr/local/bin/externalIP.txt
while true; do
	sleep 10
	exec_selftest
done
