# Create a DNS Zone
resource "aws_lightsail_domain" "myweb" {
  count       = var.lightsail ? 1 : 0
  domain_name = "${var.prefix}.com"
}

# Allocate a Static (Public) IP
resource "aws_lightsail_static_ip" "myweb" {
  count = var.lightsail ? 1 : 0
  name  = "static-ip_${var.prefix}"
}

# Add Public Key as authorized
resource "aws_lightsail_key_pair" "myweb" {
  count      = var.lightsail ? 1 : 0
  name       = var.prefix
  public_key = file("~/.ssh/${var.prefix}.pub")
}

# Create an Ubuntu Virtual Machine with key based access and run a script on boot
resource "aws_lightsail_instance" "myweb" {
  count             = var.lightsail ? 1 : 0
  name              = "site_${var.prefix}"
  availability_zone = "${var.region}a"
  blueprint_id      = "ubuntu_18_04"
  bundle_id         = "micro_2_0"
  key_pair_name     = var.prefix
  user_data         = file("scripts/install.sh")

  tags = {
        Site = "${var.prefix}.com"
    }
}

# Attach the Static (Public) IP
resource "aws_lightsail_static_ip_attachment" "myweb" {
  count          = var.lightsail ? 1 : 0
  static_ip_name = element(aws_lightsail_static_ip.myweb[*].name, 0)
  instance_name  = element(aws_lightsail_instance.myweb[*].name, 0)
}
