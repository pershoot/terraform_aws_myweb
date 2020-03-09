output "static_public_ip" {
  value = "${aws_lightsail_static_ip.myweb.ip_address}"
}
