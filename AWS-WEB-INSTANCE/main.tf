provider "aws" {
  region = "ap-south-1"
}

# Key Pair
resource "aws_key_pair" "deployer" {
  key_name   = "ssh-key"
  public_key = file("ssh-key.pub")
}

# Security Group
resource "aws_security_group" "web_sg" {
  name = "web_sg"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
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

# EC2 Instance
resource "aws_instance" "web_server" {

  ami           = "ami-0f5ee92e2d63afc18"
  instance_type = "t3.micro"

  key_name = aws_key_pair.deployer.key_name

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Welcome to My Terraform Web Server</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "Terraform-WebServer"
  }
}

# Output
output "public_ip" {
  value = aws_instance.web_server.public_ip
}