variable "public_key_path" {
  default = "~/.ssh/tform_deploy.pub"
}

variable "private_key_path" {
  default = "~/.ssh/tform_deploy"
}

variable "vpc_cidr_block" {
  default = "10.1.0.0/16"
}

variable "subnet_cidr_block" {
  default = "10.1.1.0/24"
}
