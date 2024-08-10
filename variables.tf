variable "region" {
  type    = string
  default = "sa-east-1"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "db_name" {
  type    = string
}

variable "db_username" {
  type    = string
}

variable "db_password" {
  type    = string
}

variable "ami_id" {
  type    = string
  default = "ami-09523541dfaa61c85"
}
