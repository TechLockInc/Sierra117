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
echo 
echo -e "\e[1mPenetration Testing Service - Sierra117 Virtual Appliance Finalizing Script\e[1m"
echo

# Create the startup service
echo
echo -e "\e[0;32m + Configuring console helper to run on startup...\e[0m"
cat << EOF > /etc/systemd/system/console.service
[Unit]
Description=Sierra117 Console Helper
After=systemd-logind.service

[Service]
Type=idle
ExecStart=/usr/local/bin/SelfTest.sh
StandardInput=tty
StandardOutput=tty
TTYPath=/dev/tty1
TTYVHangup=yes
Restart=always

[Install]
WantedBy=multi-user.target
EOF

chmod 644 /etc/systemd/system/console.service
systemctl enable console.service
systemctl daemon-reload
echo -e "\e[0;32m...done!\e[0m"

#Create OpenVPN config file
echo -e "\e[0;32m Creating client certificate...\e[0m"
echo "Please enter client code: "
read CC
echo
cd /usr/share/easy-rsa
source ./vars
./clean-all
cp /etc/openvpn/{ca.crt,ca.key} ./keys/
./build-key $CC
cp keys/{$CC.crt,$CC.key} /etc/openvpn/
cd /etc/openvpn
cat << EOF > client.ovpn
remote connect.techlock-pentest.com 8443 #domain
remote 34.208.45.240 8443 #PublicIP
proto tcp
dev tap
resolv-retry 600
verb 3

client
nobind
comp-lzo
persist-key
persist-tun
ns-cert-type server

EOF

#Import certificates into config file
echo "<ca>" >> client.ovpn
cat ca.crt >> client.ovpn
echo "</ca>" >> client.ovpn
echo "<cert>" >> client.ovpn
cat $CC.crt >> client.ovpn
echo "</cert>" >> client.ovpn
echo "<key>" >> client.ovpn
cat $CC.key >> client.ovpn
echo "</key>" >> client.ovpn
rm {$CC.crt,$CC.key}
echo -e "\e[0;32m ...done!\e[0m"

#Set up OpenVPN to run on startup, all console output will be stored in /root/VPN.log
echo
echo -e "\e[0;32m + Configuring configuring OpenVPN to run on startup...\e[0m"
mkdir /opt/logs
sed -i "\$i openvpn --config /etc/openvpn/client.ovpn >> /opt/logs/VPN.log &" /etc/rc.local
sed -i "\$i echo 1 > /proc/sys/net/ipv4/ip_forward" /etc/rc.local
sed -i "\$i iptables -t nat -A POSTROUTING -j MASQUERADE" /etc/rc.local
echo -e "\e[0;32m...done!\e[0m"
