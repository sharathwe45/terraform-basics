provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "example" {
  ami           = "ami-0b37e9efc396e4c38"
  instance_type = "t2.micro"
}

output "web_public_dns" {
  value = "${aws_instance.example.public_dns}"
}