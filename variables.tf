variable "aws_region"{
  default = "us-east-1"
}

variable "ami_id" {
  default = "ami-04b4f1a9cf54c11d0"
}

variable "ami_asg_id" {
  default = "ami-00db0ffce3248e509"
}

variable "ami_monitoring_id" {
  default = "ami-033a5a4bbfc0add4b"
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

variable "db_allocated_storage" {
  type        = number
  default     = 20
  description = "DB size"
}

variable "volume_size" {
  type        = number
  default     = 30
  description = "volume size"
}
