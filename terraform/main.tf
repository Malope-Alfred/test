provider "aws" {
  region = "af-south-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main_vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main_igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public_route_table"
  }
}

resource "aws_subnet" "public" {
  count = 3
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "public_subnet_${count.index}"
  }
}

resource "aws_route_table_association" "public" {
  count          = 3
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public.id
}

data "aws_availability_zones" "available" {}

resource "aws_db_subnet_group" "bean_gardener" {
  name       = "bean_gardener_test"
  subnet_ids = aws_subnet.public[*].id

  tags = {
    Name = "bean_gardener_subnet"
  }
}

resource "aws_security_group" "bean_gardener_rds" {
  name   = "bean_gardener_rds"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bean_gardener_rds"
  }
}

resource "aws_db_parameter_group" "bean_gardener" {
  name   = "beangardenertesttest"
  family = "postgres16"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}

resource "aws_db_instance" "bean_gardener" {
  identifier             = "beangardenertesttest"
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
