output "static_public_ip" {
  value = var.lightsail ? element(aws_lightsail_static_ip.myweb[*].ip_address, 0) : element(aws_eip.external[*].public_ip, 0)
}

resource "local_file" "hosts" {
  content              = trimspace("[vps]\n${var.lightsail ? element(aws_lightsail_static_ip.myweb[*].ip_address, 0) : element(aws_eip.external[*].public_ip, 0)} ansible_connection=ssh ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/${var.prefix} instance=${var.lightsail ? element(aws_lightsail_instance.myweb[*].name, 0) : element(aws_instance.myweb[*].tags["Name"], 0)} ${var.lightsail ? "" : "instance_sg=${element(aws_security_group.myweb[*].name, 0)}"} ${var.lightsail ? "" : "instance_sg_id=${element(aws_security_group.myweb[*].id, 0)}"} ${var.lightsail ? "" : "instance_vpc_id=${element(aws_vpc.myweb[*].id, 0)}"}")
  filename             = pathexpand("~/dev/ansible/hosts-aws")
  directory_permission = 0754
  file_permission      = 0664
}
