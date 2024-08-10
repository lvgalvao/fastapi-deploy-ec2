# Provedor AWS
provider "aws" {
  region = "sa-east-1"
}

# Criar uma nova VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main-vpc"
  }
}

# Criar uma subnet pública para a EC2
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

# Criar uma subnet privada para o PostgreSQL
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "private-subnet"
  }
}

# Criar um gateway de internet para a VPC
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# Criar uma tabela de roteamento para a subnet pública
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Associar a tabela de roteamento pública à subnet pública
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group para permitir acesso à instância EC2 e ao RDS
resource "aws_security_group" "allow_ec2_rds" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]  # Permitir tráfego da subnet pública
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ec2_rds"
  }
}

# Security Group para permitir acesso SSH à instância EC2
resource "aws_security_group" "allow_ssh" {
  vpc_id = aws_vpc.main.id

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

  tags = {
    Name = "allow_ssh"
  }
}

# RDS PostgreSQL na subnet privada
resource "aws_db_instance" "postgres" {
  engine            = "postgres"
  instance_class    = "db.t2.micro"
  allocated_storage = 20
  db_name           = var.db_name
  username          = var.db_username
  password          = var.db_password
  publicly_accessible = false
  vpc_security_group_ids = [aws_security_group.allow_ec2_rds.id]
  db_subnet_group_name = aws_db_subnet_group.postgres.name
  skip_final_snapshot = true

  tags = {
    Name = "Terraform-Postgres"
  }
}

# Criar um grupo de subnets para o RDS PostgreSQL
resource "aws_db_subnet_group" "postgres" {
  name       = "postgres-subnet-group"
  subnet_ids = [aws_subnet.private.id]

  tags = {
    Name = "Postgres Subnet Group"
  }
}

# Instância EC2 na subnet pública
resource "aws_instance" "web" {
  ami           = "ami-09523541dfaa61c85"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  security_groups = [
    aws_security_group.allow_ec2_rds.name,
    aws_security_group.allow_ssh.name
  ]

  depends_on = [aws_db_instance.postgres]

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    db_username = var.db_username,
    db_password = var.db_password,
    db_address  = aws_db_instance.postgres.address,
    db_name     = var.db_name
  })

  tags = {
    Name = "Terraform-EC2"
  }
}
