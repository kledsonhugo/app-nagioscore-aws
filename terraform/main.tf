resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = "true"
  tags = {
    Name = "nagios-vpc"
  }
}

resource "aws_internet_gateway" "igw_vpc" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "nagios-igw"
  }
}

resource "aws_subnet" "sn_vpc" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1a"
  tags = {
    Name = "nagios-subnet"
  }
}

resource "aws_route_table" "rt_vpc" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_vpc.id
  }
  tags = {
    Name = "nagios-rt"
  }
}

resource "aws_route_table_association" "rt_vpc_To_sn_vpc" {
  subnet_id      = aws_subnet.sn_vpc.id
  route_table_id = aws_route_table.rt_vpc.id
}

resource "aws_security_group" "sg_vpc" {
  name        = "sg_vpc"
  description = "sg_vpc"
  vpc_id      = aws_vpc.vpc.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
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
    Name = "nagios-sg"
  }
}

data "template_file" "nagios-core" {
  template = file("./scripts/nagios-core.sh")
}

resource "aws_instance" "nagios-core" {
  ami                    = "ami-0a1179631ec8933d7"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.sn_vpc.id
  vpc_security_group_ids = [aws_security_group.sg_vpc.id]
  key_name               = "vockey"
  user_data              = base64encode(data.template_file.nagios-core.rendered)
  tags = {
    Name = "nagios-core"
  }
}

data "template_file" "nagios-agent" {
  template = file("./scripts/nagios-agent.sh")
}

resource "aws_instance" "nagios-agent" {
  ami                    = "ami-0a1179631ec8933d7"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.sn_vpc.id
  vpc_security_group_ids = [aws_security_group.sg_vpc.id]
  key_name               = "vockey"
  user_data              = base64encode(data.template_file.nagios-agent.rendered)
  tags = {
    Name = "nagios-agent"
  }
}