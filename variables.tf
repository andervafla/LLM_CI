variable "aws_region"{
  default = "us-east-1"
}

variable "ami_id" {
  default = "ami-04b4f1a9cf54c11d0"
}

variable "key_name" {
  default = "my-key"
}

variable "my_ip" {
  default = "0.0.0.0/0"
}

variable "db_username" {
  type = string
  description = "Database username"
}

variable "db_password" {
  type = string
  description = "Database password"
  sensitive = true
}


