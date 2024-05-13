#!/bin/bash

# Nagios Core Install Instructions
# doc: https://support.nagios.com/kb/article/nagios-core-installing-nagios-core-from-source-96.html

echo start > /tmp/nagios-core.progress

echo setenforce >> /tmp/nagios-core.progress
setenforce 0

echo packages >> /tmp/nagios-core.progress
yum update -y
amazon-linux-extras install -y epel
yum --enablerepo=powertools,epel install perl-Net-SNMP -y
yum install -y gcc glibc glibc-common make gettext automake autoconf wget openssl-devel net-snmp net-snmp-utils epel-release
yum install -y openssl-devel
yum install -y perl-Net-SNMP
yum install -y unzip httpd php gd gd-devel perl postfix

echo nagios-core >> /tmp/nagios-core.progress
cd /tmp
wget -O nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/archive/nagios-4.5.2.tar.gz
tar xzf nagioscore.tar.gz
cd /tmp/nagioscore-nagios-4.5.2/
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
systemctl start httpd.service
systemctl start nagios.service

echo nagios-plugins >> /tmp/nagios-core.progress
cd /tmp
wget --no-check-certificate -O nagios-plugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/archive/release-2.4.6.tar.gz
tar zxf nagios-plugins.tar.gz
cd /tmp/nagios-plugins-release-2.4.6/
./tools/setup
./configure
make
make install
echo Nagios-Core > /var/www/html/index.html

echo nagios-restart >> /tmp/nagios-core.progress
systemctl start nagios.service

echo end >> /tmp/nagios-core.progress