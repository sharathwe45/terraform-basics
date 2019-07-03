
provider "aws" {
  region = "${var.region}"
}
resource "random_string" "random_name" {
  length = 10
  special = false
  upper = false
}

resource "tls_private_key" "we45_test_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh" {
  key_name   = "we45_test_key-${random_string.random_name.result}"
  public_key = "${tls_private_key.we45_test_key.public_key_openssh}"
}


resource "aws_instance" "web" {
  ami                    = "${var.ami}"
  instance_type          = "t2.micro"
  key_name               = "${aws_key_pair.ssh.key_name}"
  vpc_security_group_ids = [ "${aws_security_group.securtiy_group.id}" ]
  associate_public_ip_address = true
  source_dest_check = false

  provisioner "remote-exec" {
    connection {
        host = "${aws_instance.web.public_ip}"
        type = "ssh"
        user = "ubuntu"
        private_key = "${tls_private_key.we45_test_key.private_key_pem}"
        timeout = "5m"
        agent = false
    }

    inline = [
      "sudo apt-get update -y && apt-get upgrade -y",
      "sudo apt-get install nginx -y"
    ]
  }

  tags = {
    Name = "we45-web-app--${random_string.random_name.result}"
  }
}

resource "local_file" "aws_key" {
  content = "${tls_private_key.we45_test_key.private_key_pem}"
  filename = "we45_test_key.pem"
}

output "web_public_dns" {
  value = "${aws_instance.web.public_dns}"
}