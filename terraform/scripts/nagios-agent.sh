#!/bin/bash

# NCPA Agent Install instructions
# doc: https://assets.nagios.com/downloads/ncpa/docs/Installing-NCPA.pdf
yum update -y
rpm -Uvh https://assets.nagios.com/downloads/ncpa/ncpa-latest.el7.x86_64.rpm
systemctl restart ncpa_listener.service
echo done > /tmp/nagios-agent.progress

# SNMP Agent install instructions
# doc: https://www.site24x7.com/help/admin/adding-a-monitor/configuring-snmp-linux.html
yum update -y
yum install net-snmp -y
echo "rocommunity public" >> /etc/snmp/snmpd.conf
service snmpd restart
echo done > /tmp/snmp-agent.progress