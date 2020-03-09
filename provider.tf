provider "aws" {
  version                 = ">= 2.0"

  region                  = "${var.region}"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "default"
}
