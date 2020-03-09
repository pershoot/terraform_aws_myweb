# Create a DNS Zone
resource "aws_route53_zone" "myweb" {
  count   = var.lightsail ? 0 : 1
  name    = "${var.prefix}.com"
  comment = "${var.prefix}.com (Public)"

  tags = {
        Site = "${var.prefix}.com"
        Name = "${var.prefix}-dn"
    }
}

# Create a Security Group and allow inbound port(s)
resource "aws_security_group" "myweb" {
  count       = var.lightsail ? 0 : 1
  name        = var.prefix
  description = "Allow Ports"
  vpc_id      = element(aws_vpc.myweb[*].id, 0)

  ingress {
       from_port   = 22
       to_port     = 22
       protocol    = "tcp"
       cidr_blocks = ["0.0.0.0/0"]
       description = "SSH"
    }

  egress {
       from_port   = 0
       to_port     = 0
       protocol    = "-1"
       cidr_blocks = ["0.0.0.0/0"]
       description = "All"
    }

  tags = {
        Site = "${var.prefix}.com"
        Name = "${var.prefix}-sg"
    }
}

# Create a Virtual Private Cloud
resource "aws_vpc" "myweb" {
  count            = var.lightsail ? 0 : 1
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
        Site = "${var.prefix}.com"
        Name = "${var.prefix}-vpc"
    }
}

# Add a Subnet
resource "aws_subnet" "internal" {
  count             = var.lightsail ? 0 : 1
  vpc_id            = element(aws_vpc.myweb[*].id, 0)
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.region}a"

  tags = {
        Site = "${var.prefix}.com"
        Name = "internal"
    }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "myweb" {
  count  = var.lightsail ? 0 : 1
  vpc_id = element(aws_vpc.myweb[*].id, 0)

  tags = {
        Site = "${var.prefix}.com"
        Name = "${var.prefix}-igw"
    }
}

# Allocate a Static Public IP
resource "aws_eip" "external" {
  count             = var.lightsail ? 0 : 1
  vpc               = true
  instance          = element(aws_instance.myweb[*].id, 0)
  depends_on        = [aws_internet_gateway.myweb]

  tags = {
        Site = "${var.prefix}.com"
        Name = "external"
    }
}

# Add a route to the Internet Gateway
resource "aws_route_table" "myweb" {
  count  = var.lightsail ? 0 : 1
  vpc_id = element(aws_vpc.myweb[*].id, 0)

  route {
       cidr_block = "0.0.0.0/0"
       gateway_id = element(aws_internet_gateway.myweb[*].id, 0)
    }

  tags = {
        Site = "${var.prefix}.com"
        Name = "${var.prefix}-rt"
    }
}

# Associate the route table with the Subnet
resource "aws_route_table_association" "myweb" {
  count          = var.lightsail ? 0 : 1
  subnet_id      = element(aws_subnet.internal[*].id, 0)
  route_table_id = element(aws_route_table.myweb[*].id, 0)
}

# Add Public Key as authorized
resource "aws_key_pair" "myweb" {
  count      = var.lightsail ? 0 : 1
  key_name   = var.prefix
  public_key = file("~/.ssh/${var.prefix}.pub")
}

# Select Ubuntu 18.04
data "aws_ami" "ubuntu" {
  count       = var.lightsail ? 0 : 1
  most_recent = true

  filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
    }

  filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

  owners = ["099720109477"] # Canonical
}

# Create an Ubuntu Virtual Machine with key based access and run a script on boot
resource "aws_instance" "myweb" {
  count                    = var.lightsail ? 0 : 1
  ami                      = element(data.aws_ami.ubuntu[*].id, 0)
  instance_type            = "t3a.micro"
  availability_zone        = "${var.region}a"
  key_name                 = var.prefix
  vpc_security_group_ids   = [element(concat(aws_security_group.myweb[*].id, list("")), 0)]
  user_data                = file("scripts/install.sh")
  subnet_id                = element(aws_subnet.internal[*].id, 0)
  tenancy                  = "default"

  tags = {
        Site = "${var.prefix}.com"
        Name = "${var.prefix}-ec2"
    }
}
