provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Main VPC"
  }
}

terraform {
   backend "s3" {
    bucket = "tfstate23545345"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

locals {
  public_subnets = {
    public_subnet_1 = {
      cidr_block        = "10.0.1.0/24"
      availability_zone = "us-east-1a"
    }
    public_subnet_2 = {
      cidr_block        = "10.0.2.0/24"
      availability_zone = "us-east-1b"
    }
  }

  private_subnets = {
    private_subnet_1 = {
      cidr_block        = "10.0.3.0/24"
      availability_zone = "us-east-1a"
    }
    private_subnet_2 = {
      cidr_block        = "10.0.4.0/24"
      availability_zone = "us-east-1b"
    }
  }

  rds_subnets = {
    private_subnet_rds_1 = {
      cidr_block        = "10.0.5.0/24"
      availability_zone = "us-east-1a"
    }
    private_subnet_rds_2 = {
      cidr_block        = "10.0.6.0/24"
      availability_zone = "us-east-1b"
    }
  }
}

resource "aws_subnet" "public" {
  for_each                = local.public_subnets
  vpc_id                   = aws_vpc.main.id
  cidr_block               = each.value.cidr_block
  availability_zone        = each.value.availability_zone
  map_public_ip_on_launch  = true
  tags = {
    Name = "Public Subnet ${each.key}"
  }
}

resource "aws_subnet" "private" {
  for_each         = local.private_subnets
  vpc_id           = aws_vpc.main.id
  cidr_block       = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags = {
    Name = "Private Subnet ${each.key}"
  }
}

resource "aws_subnet" "rds" {
  for_each         = local.rds_subnets
  vpc_id           = aws_vpc.main.id
  cidr_block       = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags = {
    Name = "RDS Subnet ${each.key}"
  }
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rds" {
  for_each       = aws_subnet.rds
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "Private Route Table"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
    tags = {
    Name = "Main IGW"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"
    tags = {
    Name = "NAT EIP"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public["public_subnet_1"].id
    tags = {
    Name = "Main NAT Gateway"
  }
}

resource "aws_security_group" "bastion_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Bastion Security Group"
  }
}

resource "aws_security_group" "private_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  ingress {
    from_port   = 12345
    to_port     = 12345
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  ingress {
  from_port   = 9100
  to_port     = 9100
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]  
}

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Private Security Group"
  }
}

resource "aws_key_pair" "my_key" {
  key_name   = "my-key"
  public_key = file("key/my-key.pub")
}

resource "aws_instance" "bastion" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public["public_subnet_1"].id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name               = var.key_name

  tags = {
    Name = "Bastion Host"
  }
}

resource "aws_security_group" "monitoring_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    security_groups = [aws_security_group.private_sg.id]
  }
  ingress {
    from_port   = 12345
    to_port     = 12345
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  egress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    security_groups = [aws_security_group.private_sg.id] 
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]  
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Monitoring Security Group"
  }
}

resource "aws_instance" "monitoring_instance" {
  ami                    = var.ami_monitoring_id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public["public_subnet_2"].id 
  vpc_security_group_ids = [aws_security_group.monitoring_sg.id]
  key_name               = var.key_name

  iam_instance_profile = aws_iam_instance_profile.monitoring_profile.name

  tags = {
    Name = "Monitoring Instance"
  }
}

resource "aws_lb" "main" {
  name               = "main-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = values(aws_subnet.public)[*].id
  enable_deletion_protection = false

  tags = {
    Name = "Application Load Balancer"
  }
}

# Security Group для ALB
resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ALB Security Group"
  }
}

resource "aws_lb_target_group" "tg" {
  name     = "main-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 300
  }
}

resource "aws_lb_target_group" "monit_tg" {
  name     = "monit-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/api/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 300
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }

  tags = {
    Name = "HTTP Listener"
  }
}

resource "aws_lb_listener" "monitoring" {
  load_balancer_arn = aws_lb.main.arn
  port              = "3000"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.monit_tg.arn
  }

  tags = {
    Name = "Monitoring Listener"
  }
}

resource "aws_lb_target_group_attachment" "monitoring_tg_attachment" {
  target_group_arn = aws_lb_target_group.monit_tg.arn
  target_id        = aws_instance.monitoring_instance.id
  port             = 3000
}


resource "aws_launch_template" "launch_template" {
  name          = "launch-template"
  image_id      = var.ami_asg_id
  instance_type = "t3.xlarge"
  key_name      = var.key_name

 iam_instance_profile {
    name = aws_iam_instance_profile.llm_profile.name
  }

  network_interfaces {
    security_groups = [aws_security_group.private_sg.id] 
    associate_public_ip_address = false
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 30 
      volume_type = "gp3"
      delete_on_termination = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
   tags = {
    Name = "Launch Template"
  }
}

resource "aws_autoscaling_group" "asg" {
  desired_capacity     = 1
  max_size             = 1
  min_size             = 1
  vpc_zone_identifier = values(aws_subnet.private)[*].id

  launch_template {
    name    = aws_launch_template.launch_template.name
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.tg.arn]

  tag {
    key                 = "Name"
    value               = "AutoScaling EC2"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    security_groups = [aws_security_group.private_sg.id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDS Security Group"
  }
}

resource "aws_db_instance" "rds_instance" {
  allocated_storage = 20
  engine = "postgres"
  engine_version = "15"
  instance_class = "db.t3.micro"
  db_name = "mydatabase"
  username = var.db_username
  password = var.db_password
  parameter_group_name = "default.postgres15"
  skip_final_snapshot = true
  publicly_accessible = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name  = aws_db_subnet_group.rds_subnet_group.name
   tags = {
    Name = "RDS Instance"
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = values(aws_subnet.rds)[*].id
  tags = {
    Name = "RDS Subnet Group"
  }
}

