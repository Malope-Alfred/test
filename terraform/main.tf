provider "aws" {
  region = "af-south-1"
  access_key = var.ACCESS_KEY
  secret_key = var.SECRET_KEY
  token = var.SESSION_TOKEN
}

resource "aws_db_instance" "bean-gardner" {
  identifier             = "bean-gardner"
  instance_class         = "db.t4.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "16.3"
  username               = var.db_username
  password               = var.db_password
  publicly_accessible    = true
  skip_final_snapshot    = true

  tags = {
    name = "bean-gardner-db"
  }
}

# Define variables
variable "db_username" {
  description = "Database username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "ACCESS_KEY" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "SECRET_KEY" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "SESSION_TOKEN" {
  description = "Database password"
  type        = string
  sensitive   = true
}
