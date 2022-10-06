#!/bin/bash

# Nagios Core Install Instructions
# https://support.nagios.com/kb/article/nagios-core-installing-nagios-core-from-source-96.html
yum update -y
setenforce 0
cd /tmp
yum install -y gcc glibc glibc-common make gettext automake autoconf wget openssl-devel net-snmp net-snmp-utils epel-release
yum install -y perl-Net-SNMP
yum install -y unzip httpd php gd gd-devel perl postfix
cd /tmp
wget -O nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/archive/nagios-4.4.6.tar.gz
tar xzf nagioscore.tar.gz
cd /tmp/nagioscore-nagios-4.4.6/
./configure
make all
make install-groups-users
usermod -a -G nagios apache
make install
make install-daemoninit
systemctl enable httpd.service
make install-commandmode
make install-config
make install-webconf
iptables -I INPUT -p tcp --destination-port 80 -j ACCEPT
ip6tables -I INPUT -p tcp --destination-port 80 -j ACCEPT
htpasswd -b -c /usr/local/nagios/etc/htpasswd.users nagiosadmin nagiosadmin
service httpd start
service nagios start
cd /tmp
wget --no-check-certificate -O nagios-plugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/archive/release-2.3.3.tar.gz
tar zxf nagios-plugins.tar.gz
cd /tmp/nagios-plugins-release-2.3.3/
./tools/setup
./configure
make
make install
service nagios restart
echo done > /tmp/nagioscore.done