resource "aws_lightsail_domain" "myweb" {
  domain_name = "myweb.com"
}

resource "aws_lightsail_static_ip" "myweb" {
  name = "static-ip_myweb"
}

resource "aws_lightsail_instance" "myweb" {
  name              = "site_myweb"
  availability_zone = "${var.region}a"
  blueprint_id      = "ubuntu_18_04"
  bundle_id         = "micro_2_0"
  key_pair_name     = "myweb"
  user_data         = data.template_file.init_script.rendered

  tags = {
        Site = "myweb.com"
    }
}

resource "aws_lightsail_static_ip_attachment" "myweb" {
  static_ip_name = aws_lightsail_static_ip.myweb.name
  instance_name  = aws_lightsail_instance.myweb.name
}
