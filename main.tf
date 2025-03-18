provider "aws" {
  region = "us-east-1"
}

variable "db_password" {}
variable "db_username" {}

data "aws_subnet" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = ["tech-challenge-vpc-vpc"]
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [for subnet in data.aws_subnet.private_subnets : subnet.id]

  tags = {
    Name = "RDS Subnet Group"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-tech-challenge-security-group"
  description = "Permitir acesso ao RDS na VPC"
  vpc_id      = "tech-challenge-vpc-vpc"  # ID da sua VPC

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  tags = {
    Name = "RDS Security Group"
  }
}

resource "aws_db_instance" "rds_postgres" {
  identifier             = "tech-challenge-postgres"
  engine                 = "postgres"
  engine_version         = "15.4"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.postgres15"
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  skip_final_snapshot    = true
}
