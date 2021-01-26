#!/bin/sh

setenforce 0

wget -O /etc/yum.repos.d/epel-7.repo http://mirrors.aliyun.com/repo/epel-7.repo

yum install iptables iptables-services openvpn -y

cd /opt/

wget https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.8/EasyRSA-3.0.8.tgz

tar xf EasyRSA-3.0.8.tgz

cp -r EasyRSA-3.0.8 /etc/openvpn/easy-rsa3

cp /etc/openvpn/easy-rsa3/vars.example /etc/openvpn/easy-rsa3/vars

cd /etc/openvpn/easy-rsa3/

./easyrsa init-pki

./easyrsa build-ca nopass

./easyrsa gen-req server nopass

./easyrsa sign-req server server

./easyrsa gen-req client nopass

./easyrsa sign-req client client

./easyrsa gen-dh

openvpn --genkey --secret /etc/openvpn/ta.key

cd /etc/openvpn/easy-rsa3/pki/

cp ca.crt dh.pem /etc/openvpn/

cp private/server.key issued/server.crt /etc/openvpn/server/

cp private/client.key issued/client.crt /etc/openvpn/client/

wget https://raw.githubusercontent.com/HXHGTS/OpenVPN-Server-Create/master/server.conf -O /etc/openvpn/server.conf

wget https://raw.githubusercontent.com/HXHGTS/OpenVPN-Server-Create/master/client.conf -O /etc/openvpn/client.conf

chown root.openvpn /etc/openvpn/* -R

echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf

sysctl -p 

iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o eth0 -j MASQUERADE

iptables -I INPUT -p tcp --dport 10010 -j ACCEPT

service iptables save

systemctl restart iptables

systemctl start openvpn@server

netstat -lntp|grep openvpn

ps -aux|grep openvpn
