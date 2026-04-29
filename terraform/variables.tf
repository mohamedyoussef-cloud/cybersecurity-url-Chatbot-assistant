variable "aws_region" {
  default = "us-east-1"
}

variable "netid" {
  description = "Queen's NetID or student identifier prefix"
  type        = string
}

variable "my_ip_cidr" {
  description = "Your IP address in CIDR format, example 1.2.3.4/32"
  type        = string
}

variable "public_key_path" {
  description = "Path to SSH public key"
  type        = string
}

variable "ami_id" {
  description = "Ubuntu AMI ID"
  type        = string
}
