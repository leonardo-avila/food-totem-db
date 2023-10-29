terraform{
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
  
  required_version = ">= 1.3.7"

  backend "s3" {
    bucket                  = "jwt-lambda-terraform"
    key                     = "food-totem-dbs/terraform.tfstate"
    region                  = "us-east-1"
  }
}
provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      app = "food-totem-db"
    }
  }
}

resource "aws_security_group" "rds_sg" {
  name = "rds_sg"
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_parameter_group" "mysql-parameter-group" {
  name        = "mysql-parameter-group"
  family      = "mysql8.0"
  description = "Default parameter group for MySQL 8.0"
}


resource "aws_db_instance" "food-totem-mysql" {
  engine               = "mysql"
  identifier           = "food-totem-mysql"
  allocated_storage    =  20
  engine_version       = "8.0.33"
  instance_class       = "db.t2.micro"
  username             = var.mysql_user
  password             = var.mysql_password
  parameter_group_name = "mysql-parameter-group"
  vpc_security_group_ids = ["${aws_security_group.rds_sg.id}"]
  skip_final_snapshot  = true
  publicly_accessible =  true
}

