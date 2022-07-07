provider "aws" {
  region = "eu-west-2"
}

resource "aws_instance" "bm_server" {
  ami = "ami-078a289ddf4b09ae0"
  instance_type = "t2.micro"

  tags = {
    "Name" = "test_instance"
  }
}