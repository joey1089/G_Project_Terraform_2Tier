# --- network/main.tf ---


#Create Custom VPC
resource "aws_vpc" "myvpc_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "myvpc_vpc"
  }
}
# create subnet for each AZ's
resource "aws_subnet" "subnet_east1a" {
  vpc_id                  = aws_vpc.myvpc_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet-us-east-1a"
  }
}
resource "aws_subnet" "subnet_east1b" {
  vpc_id                  = aws_vpc.myvpc_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet-us-east-1b"
  }
}
resource "aws_subnet" "subnet_east1c" {
  vpc_id                  = aws_vpc.myvpc_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet-us-east-1c"
  }
}

#Create internet gateway 
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc_vpc.id
  tags = {
    Name = "igw"
  }
}

#Create a Route Table and add router with igw and allow all
resource "aws_route_table" "igw_public_rt" {
  vpc_id = aws_vpc.myvpc_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "Route Table"
  }
}

#Create Route Table explicit assoication  with the public subnet
resource "aws_route_table_association" "public_rt1" {
  subnet_id      = aws_subnet.subnet_east1a.id
  route_table_id = aws_route_table.igw_public_rt.id
}
resource "aws_route_table_association" "public_rt2" {
  subnet_id      = aws_subnet.subnet_east1b.id
  route_table_id = aws_route_table.igw_public_rt.id
}
resource "aws_route_table_association" "public_rt3" {
  subnet_id      = aws_subnet.subnet_east1c.id
  route_table_id = aws_route_table.igw_public_rt.id
}

#Create securtiy group to allow http and ssh access
resource "aws_security_group" "web_sg" {
  name        = "http_ssh_sg"
  description = "http and ssh allowed into ec2 instances"
  vpc_id      = aws_vpc.myvpc_vpc.id
  #Allow SSH access.
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #ip removed
  }

  #Allow incoming HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #ip removed
  }
  #Allow outgoing--access to web.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Create Application Load Balancer's target group
resource "aws_alb_target_group" "alb_targer_grp" {
  name     = "alb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc_vpc.id
  health_check {
    enabled             = true
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 3
  }
}
#Create Application Load Balancer target group attachment
resource "aws_lb_target_group_attachment" "attach-instance01" {
  target_group_arn = aws_alb_target_group.alb_targer_grp.arn
  target_id        = aws_instance.Instance_01.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "attach-instance02" {
  target_group_arn = aws_alb_target_group.alb_targer_grp.arn
  target_id        = aws_instance.Instance_02.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "attach-instance03" {
  target_group_arn = aws_alb_target_group.alb_targer_grp.arn
  target_id        = aws_instance.Instance_03.id
  port             = 80
}

# Create Application load balancer lister
resource "aws_lb_listener" "web_alb_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb_targer_grp.arn
  }
}
#Create Application Load Balancer 
resource "aws_lb" "web_alb" {
  name                       = "web-loadbalancer"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.web_sg.id]
  subnets                    = [aws_subnet.subnet_east1a.id, aws_subnet.subnet_east1b.id, aws_subnet.subnet_east1c.id]
  enable_deletion_protection = false
  tags = {
    Environment = "Test"
  }
}

# Create ec2_instance01 in AZ east-1a
resource "aws_instance" "Instance_01" {
  ami             = "ami-0b5eea76982371e91"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.subnet_east1a.id
  security_groups = [aws_security_group.web_sg.id]
  key_name        = "Test_KeyPair"
  tags = {
    "name" = "web-instance-1"
  }
  user_data = file("./network/user-data.sh") # working
}
#Create ec2 instance02 in AZ east-1b
resource "aws_instance" "Instance_02" {
  ami             = "ami-0b5eea76982371e91"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.subnet_east1b.id
  security_groups = [aws_security_group.web_sg.id]
  key_name        = "Test_KeyPair"
  tags = {
    "name" = "web-instance-2"
  }
  user_data = file("./network/user-data.sh")
}

#Create ec2 instance03 in AZ east-1c
resource "aws_instance" "Instance_03" {
  ami             = "ami-0b5eea76982371e91"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.subnet_east1c.id
  security_groups = [aws_security_group.web_sg.id]
  key_name        = "Test_KeyPair"
  tags = {
    "name" = "web-instance-3"
  }
  user_data = file("./network/user-data.sh")
}



