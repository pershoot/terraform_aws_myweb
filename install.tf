data "template_file" "init_script" {
  template = "${file("scripts/install.sh")}"
}
