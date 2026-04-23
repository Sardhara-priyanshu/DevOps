# ------------ Prvider --------------------

provider "aws" {
    region = "ap-south-1"
}


# --------------- Security Group ----------------

resource "aws_security_group" "lb_sg" {
    name = "lb-security-group"

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 22
        to_port     = 22
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

# ----------------- Default VPC ------------------

data "aws_vpc" "default" {
    default = true
}

data "aws_subnets" "default" {}


# ------------------- EC2 Server 1 -------------------

resource "aws_instance"  "server1" {
    ami             = "ami-048f4445314bcaa09"
    instance_type   = "t3.micro"
    key_name        = "load-balancer-key"

    security_groups = [aws_security_group.lb_sg.name]

    user_data   =   <<-EOF
                    #!/bin/bash
                    yum update  -y
                    yum install httpd -y 
                    echo "Server 1 Running" > /var/www/html/index.html
                    systemctl start httpd
                    systemctl enable httpd
                    EOF
    
    tags = {
        Name = "Server-1"
    }
}


# ------------------- EC2 Server 2 -------------------

resource "aws_instance"  "server2" {
    ami             = "ami-048f4445314bcaa09"
    instance_type   = "t3.micro"
    key_name        = "load-balancer-key"

    security_groups = [aws_security_group.lb_sg.name]

    user_data   =   <<-EOF
                    #!/bin/bash
                    yum update  -y
                    yum install httpd -y 
                    echo "Server 2 Running" > /var/www/html/index.html
                    systemctl start httpd
                    systemctl enable httpd
                    EOF
    
    tags = {
        Name = "Server-2"
    }
}


# ------------------- Load Balancer ---------------------

resource "aws_lb" "my_lb" {
    name                = "my-load-balancer"
    internal            = false
    load_balancer_type  = "application"

    security_groups = [aws_security_group.lb_sg.id]
    subnets         = data.aws_subnets.default.ids

    tags = {
        Name = "My_Load_Balancer"
    }
}


# -------------------- Target Group -------------------

resource "aws_lb_target_group" "tg" {
    name        = "my-target-group"
    port        = 80
    protocol    = "HTTP"
    vpc_id      = data.aws_vpc.default.id

    health_check {
        path    = "/"
        port    = "80"
    }

    tags = {
        Name = "Target-Group"
    }
}


# -------------------------- Attach Servers --------------------

resource "aws_lb_target_group_attachment" "server1_attach" {

    target_group_arn    = aws_lb_target_group.tg.arn
    target_id           = aws_instance.server1.id
    port                = 80
}

resource "aws_lb_target_group_attachment" "server2_attach" {

    target_group_arn    = aws_lb_target_group.tg.arn
    target_id           = aws_instance.server2.id
    port                = 80
}


# -------------------------- Listener -----------------------

resource "aws_lb_listener" "listener" {

    load_balancer_arn   = aws_lb.my_lb.arn
    port                = 80
    protocol            = "HTTP"

    default_action {
        type                = "forward"
        target_group_arn    = aws_lb_target_group.tg.arn
    }
}


# ------------------------ Output ---------------------------

output "load_balancer_dns" {
    value = aws_lb.my_lb.dns_name
}
