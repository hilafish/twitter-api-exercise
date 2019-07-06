##################################################################################
# VARIABLES
##################################################################################


variable "gen_key_name" {
  description = "Temporary AWS key name"
  default = "env_ssh_key"
}

resource "tls_private_key" "env_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "${var.gen_key_name}"
  public_key = "${tls_private_key.env_ssh_key.public_key_openssh}"
  depends_on = ["tls_private_key.env_ssh_key"]
}


##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  shared_credentials_file = "~/.aws/credentials"
  region     = "us-east-1"
}


##################################################################################
# DATA
##################################################################################

data "aws_availability_zones" "available" {}


##################################################################################
# OUTPUT
##################################################################################


output "env_key_name" {
  value       = "${element(compact(concat(aws_key_pair.generated_key.*.key_name)), 0)}"
  description = "Name of SSH key"
}

#output "env_public_key" {
#  value       = "${join("", tls_private_key.env_ssh_key.*.public_key_openssh)}"
#  description = "Contents of the generated public key"
#}

output "env_private_key" {
  value       = "${join("", tls_private_key.env_ssh_key.*.private_key_pem)}"
  description = "Name of SSH key"
}
