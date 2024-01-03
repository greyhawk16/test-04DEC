# EC2 role 생성
resource "aws_iam_role" "test_role" {
  name               = "cr-cmd_inj-role-EC2role"
  path               = "/"
  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "",
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF
}


# S3ReadOnly 정책 생성
resource "aws_iam_role_policy_attachment" "example_attachment" {
  role       = aws_iam_role.test_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}


# EC2 인스턴스 프로필 생성
resource "aws_iam_instance_profile" "cmd-inj_EC2-profile" {
  name = "cr-cmd_inj-EC2_profile-profile"
  role = "${aws_iam_role.test_role.name}"
}


resource "tls_private_key" "this" {
  algorithm     = "RSA"
  rsa_bits      = 4096
}

resource "aws_key_pair" "this" {
  key_name      = "cr-cmd_inj-key-key_pair"
  public_key    = tls_private_key.this.public_key_openssh

  provisioner "local-exec" {
    command = <<-EOT
      echo "${tls_private_key.this.private_key_pem}" > cr-cmd_inj-key-key_pair.pem
    EOT
  }
}


resource "aws_security_group" "alone_web" {
  name        = "cr-cmd_inj-SG-SecurityGroup"
  description = "cr-cmd_inj-SG-SecurityGroup"
  ingress {
    from_port = 22                                           
    to_port = 22                                             
    protocol = "tcp"                                         
    cidr_blocks = ["0.0.0.0/0"]       
  }
  ingress {
    from_port = 5000
    to_port = 5000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "app_server" {
  ami = "ami-079db87dc4c10ac91"  # AMI from "joonhun_SSTI_rev3"
  instance_type = "t3.micro"
  key_name = "${aws_key_pair.this.key_name}"
  vpc_security_group_ids = ["${aws_security_group.alone_web.id}"] 
  iam_instance_profile = "${aws_iam_instance_profile.cmd-inj_EC2-profile.name}"
  
  tags = {
    Name = "cr-cmd_inj-app_server-EC2"
  }
  root_block_device {
    volume_size         = 30 
  }

  connection {
      type = "ssh"
      user = "ec2-user"
      host = self.public_ip
      private_key = "${file(var.ssh-private-key-for-ec2)}"
  }

  provisioner "file" {
      source = "../code"
      destination = "/home/ec2-user/code"
  }

  # Write ID of created EC2 instace to "data.txt"
  provisioner "local-exec" {
    command = <<-EOT
      echo "${aws_instance.app_server.id}" > instance_id.txt
    EOT
  }

  provisioner "remote-exec" {
    inline = [
      #!/bin/bash
      "sudo yum update",
      "sudo yum install pip -y",
      "sudo yum install nc -y",
      "pip3 install flask",
      "sudo amazon-linux-extras enable nginx1.12",
      "sudo yum -y install nginx",
      "sudo systemctl start nginx",
      "nohup python3 code/app.py > /dev/null 2> /dev/null < /dev/null &",
      "sleep 10"  # required to finish "nohup"
    ]
  }
}


# EIP
resource "aws_eip" "elasticip" {
  instance = aws_instance.app_server.id

  # write public ip-address to location.txt
  provisioner "local-exec" {
    command = <<-EOT
      echo "${aws_eip.elasticip.public_ip}:5000" > location.txt
    EOT
  }
}
