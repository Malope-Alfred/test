terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.20.0"
    }
  }
}
provider "aws" {
  region = "af-south-1"
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.77.0"

  name                 = "education"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_db_subnet_group" "bean_gardener" {
  name       = "bean_gardener"
  subnet_ids = module.vpc.public_subnets

  tags = {
    Name = "bean_gardener_subnet"
  }
}

resource "aws_security_group" "bean_gardener_rds" {
  name   = "bean_gardener_rds"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bean_gardener_rds"
  }
}

resource "aws_db_parameter_group" "bean_gardener" {
  name   = "bean_gardener"
  family = "postgres16"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}


resource "aws_db_instance" "bean_gardener" {
  identifier             = "bean_gardener"
  instance_class         = "db.t4.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "16.3"
  username               = var.DB_USERNAME
  password               = var.DB_PASSWORD

  db_subnet_group_name   = aws_db_subnet_group.bean_gardener.name
  vpc_security_group_ids = [aws_security_group.bean_gardener_rds.id]
  parameter_group_name   = aws_db_parameter_group.bean_gardener.name

  publicly_accessible    = true
  skip_final_snapshot    = true

  tags = {
    name = "bean_gardener_db"
  }
}

# Define variables
variable "DB_USERNAME" {
  description = "Database username"
  type        = string
  sensitive   = true
}

variable "DB_PASSWORD" {
  description = "Database password"
  type        = string
  sensitive   = true
}

# variable "ACCESS_KEY" {
#   description = "Database password"
#   type        = string
#   sensitive   = true
# }

# variable "SECRET_KEY" {
#   description = "Database password"
#   type        = string
#   sensitive   = true
# }

# variable "SESSION_TOKEN" {
#   description = "Database password"
#   type        = string
#   sensitive   = true
# }
