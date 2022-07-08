provider "aws" {
  region = "eu-west-2"
}

resource "aws_launch_configuration" "bm_servers" {
  image_id = "ami-078a289ddf4b09ae0"
  instance_type = "t2.micro"
  security_group = [aws_security_group.instance.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello World" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF

# Required when using launch configuration with an autoscaling group.
# terraform docs

lifecycle {
  create_before_destroy = true
}

#   tags = {
#     "Name" = "test_instance"
#   }
}

resource "aws_autoscaling_group" "bm-test" {
  launch_configuration = aws_launch_configuration.bm_servers
  vpc_zone_identifier = data.aws_subnet_ids.default.ids

  min_size = 2
  max_size = 10

  tag {
    key = "Name"
    value = "terraform-asg-bm-serv"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "instance" {
  name = "terraform-test"

  ingress {
    from_port = var.server_port
    to_port = var.server_port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type = number
  default = 8080
}

output "public_ip" {
  value = aws_instance.bm_server.public_ip
  description = "The public ip of the instance"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

resource "aws_lb" "bm-test" {
  name = "terraform-asg-bm-serv"
  load_balancer_type = "application"
  subnets = data.aws_subnet_ids.default.ids
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.bm-test
  port = 80
  protocol = "HTTP"
}

# By default rerun a 404 page
default_action {
    type = "fixed-response"

    fixed_response {
        content_type = "text/plain"
        message_body = "404: page nto found"
        status_code = 404
    }
}

resource "aws_security_group" "alb" {
  name = "terraform-test"

  ingress {
    from_port = var.server_port
    to_port = var.server_port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}