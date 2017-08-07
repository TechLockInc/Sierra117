#!/bin/bash

#Written by Vu Mai
#Greeting
echo -e "\e[1m============================================================================\e[0m"
echo -e "\e[0;32m _____ _____ _____  _   _   _     _____ _____  _   __    _____              \e[0m"
echo -e "\e[0;32m|_   _|  ___/  __ \| | | | | |   |  _  /  __ \| | / /   |_   _|             \e[0m"
echo -e "\e[0;32m  | | | |__ | /  \/| |_| | | |   | | | | /  \/| |/ /      | | _ __   ___    \e[0m"
echo -e "\e[0;32m  | | |  __|| |    |  _  | | |   | | | | |    |    \      | || '_ \ / __|   \e[0m"
echo -e "\e[0;32m  | | | |___| \__/\| | | | | |___\ \_/ / \__/\| |\  \_   _| || | | | (__ _  \e[0m"
echo -e "\e[0;32m  \_/ \____/ \____/\_| |_/ \_____/\___/ \____/\_| \_( )  \___/_| |_|\___(_) \e[0m"
echo -e "\e[0;32m                                                    |/                      \e[0m"
echo -e "\e[1m============================================================================\e[0m"

echo -e "\e[0;32m Creating client certificate...\e[0m"
echo "Please enter your TECH LOCK username:"
read user
cd /usr/share/easy-rsa
source ./vars
./clean-all
cp /etc/openvpn/{ca.crt,ca.key} ./keys/
./build-key $user
cp ./keys/{$user.crt,$user.key} /etc/openvpn
echo -e "\e[0;32m ...done!\e[0m"
echo
echo -e "\e[0;32m Configuring OpenVPN client...\e[0m"
cd /etc/openvpn
cat << EOF > client.conf
client
dev tap
proto tcp
remote ec2-34-208-45-240.us-west-2.compute.amazonaws.com 443
remote 34.208.45.240 443
resolv-retry 600
nobind
persist-key
persist-tun
ca ca.crt
cert $user.crt
key $user.key
ns-cert-type server
comp-lzo
verb 3
EOF
echo -e "\e[0;32m ...done!\e[0m"
