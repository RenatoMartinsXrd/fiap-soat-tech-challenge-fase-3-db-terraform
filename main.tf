provider "aws" {
  region = "us-east-1"
}

variable "DB_PASSWORD" {}
variable "DB_USERNAME" {}

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["tech-challenge-vpc"]  # Nome da VPC específica
  }
}

data "aws_subnets" "selected" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

data "aws_rds_engine_version" "latest_postgres" {
  engine = "postgres"
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = data.aws_subnets.selected.ids

  tags = {
    Name = "RDS Subnet Group"
  }
}

data "aws_security_group" "eks_sg" {
  filter {
    name   = "tag:Name"
    values = ["eks-cluster-sg"]  # Nome fixo do Security Group do EKS
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-tech-challenge-security-group"
  description = "Permitir acesso ao RDS na VPC"
  vpc_id      = data.aws_vpc.selected.id

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

resource "aws_security_group_rule" "allow_eks_to_rds" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds_sg.id
  source_security_group_id = data.aws_security_group.eks_sg.id
}

resource "aws_db_instance" "rds_postgres" {
  identifier             = "tech-challenge-postgres"
  engine                 = "postgres"
  engine_version         = data.aws_rds_engine_version.latest_postgres.version
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  username               = var.DB_USERNAME
  password               = var.DB_PASSWORD
  parameter_group_name   = "default.postgres17"
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  skip_final_snapshot    = true
}

