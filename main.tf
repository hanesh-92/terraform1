provider "aws" {
  access_key = "AKIASADU54Z7RDKFWP7M"
  secret_key = "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"
  region     = "us-east-2"
}


resource "aws_instance" "web" {
  ami                    = "ami-09558250a3419e7d0"
  instance_type          = "t2.micro"
  key_name               = "ohio"
  vpc_security_group_ids = ["${aws_security_group.webSG.id}"]
  tags = {
    Name = "remote-exec-provisioner"
  }

}

resource "null_resource" "copy_execute" {

  connection {
    type        = "ssh"
    host        = aws_instance.web.public_ip
    user        = "ec2-user"
    private_key = file("ohio.pem")
  }

  provisioner "file" {
    source      = "index.html"
    destination = "/tmp/index.html"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd -y",
     "sudo service httpd on",
     "sudo service httpd start",
     "sudo mv /tmp/index.html /var/www/html/"
    ]
  }



  depends_on = [aws_instance.web]

}

resource "aws_security_group" "webSG" {
  name        = "webSG"
  description = "Allow ssh  inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}
