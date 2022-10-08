# VPC
resource "aws_vpc" "vpc" {
    cidr_block           = "10.0.0.0/16"
    enable_dns_hostnames = "true"

    tags = {
        Name = "vpc"
    }
}

# INTERNET GATEWAY
resource "aws_internet_gateway" "igw_vpc" {
    vpc_id = aws_vpc.vpc.id

    tags = {
        Name = "igw_vpc"
    }
}

# SUBNET
resource "aws_subnet" "sn_vpc" {
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = "10.0.0.0/24"
    map_public_ip_on_launch = "true"
    availability_zone       = "us-east-1a"

    tags = {
        Name = "sn_vpc"
    }
}

# ROUTE TABLE
resource "aws_route_table" "rt_vpc" {
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw_vpc.id
    }

    tags = {
        Name = "rt_vpc"
    }
}

# SUBNET ASSOCIATION
resource "aws_route_table_association" "rt_vpc_To_sn_vpc" {
  subnet_id      = aws_subnet.sn_vpc.id
  route_table_id = aws_route_table.rt_vpc.id
}

# SECURITY GROUP
resource "aws_security_group" "sg_vpc" {
    name        = "sg_vpc"
    description = "sg_vpc"
    vpc_id      = aws_vpc.vpc.id
    
    ingress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["10.0.0.0/16"]
    }

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "sg_vpc"
    }
}

# EC2 INSTANCE
resource "aws_instance" "nagios" {
    ami                    = "ami-02e136e904f3da870"
    instance_type          = "t2.micro"
    subnet_id              = aws_subnet.sn_vpc.id
    vpc_security_group_ids = [aws_security_group.sg_vpc.id]
	user_data = <<-EOF
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
        wget -O nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/archive/nagios-4.4.5.tar.gz
        tar xzf nagioscore.tar.gz
        cd /tmp/nagioscore-nagios-4.4.5/
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
        wget --no-check-certificate -O nagios-plugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/archive/release-2.2.1.tar.gz
        tar zxf nagios-plugins.tar.gz
        cd /tmp/nagios-plugins-release-2.2.1/
        ./tools/setup
        ./configure
        make
        make install
        service nagios restart
        echo done > /tmp/nagioscore.done
	EOF

    tags = {
        Name = "nagios"
    }
}

resource "aws_instance" "node_a" {
    ami                    = "ami-02e136e904f3da870"
    instance_type          = "t2.micro"
    subnet_id              = aws_subnet.sn_vpc.id
    vpc_security_group_ids = [aws_security_group.sg_vpc.id]
	user_data = <<-EOF
        #!/bin/bash

        # NCPA Agent Install instructions
        # https://assets.nagios.com/downloads/ncpa/docs/Installing-NCPA.pdf
        yum update -y
        rpm -Uvh https://assets.nagios.com/downloads/ncpa/ncpa-latest.el7.x86_64.rpm
        systemctl restart ncpa_listener.service
        echo done > /tmp/ncpa-agent.done

        # SNMP Agent install instructions
        # https://www.site24x7.com/help/admin/adding-a-monitor/configuring-snmp-linux.html
        yum update -y
        yum install net-snmp -y
        echo "rocommunity public" >> /etc/snmp/snmpd.conf
        service snmpd restart
        echo done > /tmp/snmp-agent.done
	EOF

    tags = {
        Name = "node_a"
    }
}