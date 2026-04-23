provider "aws" {
  region = "ap-south-1"
}

resource "aws_db_instance" "database" {
  allocated_storage    = 5
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"

  db_name              = "GujaratTitans"
  username             = "priyanshu"
  password             = "priyanshu_0709"

  skip_final_snapshot  = true
  publicly_accessible  = true

  vpc_security_group_ids = ["sg-0779783d58ab7dc2c"]
}