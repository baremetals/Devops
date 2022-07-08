provider "aws" {
  region = "eu-west-2"
}

resource "aws_instance" "bm_server" {
  ami = "ami-078a289ddf4b09ae0"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.instance.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello World" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF

  tags = {
    "Name" = "test_instance"
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
