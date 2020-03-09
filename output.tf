output "static_public_ip" {
  value = aws_lightsail_static_ip.myweb.ip_address
}

resource "local_file" "hosts" {
  content              = "[vps]\n${aws_lightsail_static_ip.myweb.ip_address} ansible_connection=ssh ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/myweb instance=${aws_lightsail_instance.myweb.name}"
  filename             = "${path.module}/../../ansible/hosts"
  directory_permission = 0754
  file_permission      = 0664
}
