# Provedor AWS
provider "aws" {
  region = "sa-east-1"
}

# Obter a VPC padrão
data "aws_vpc" "default" {
  default = true
}

# Obter a subrede padrão
data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

# Obter o primeiro ID de subrede (apenas como exemplo)
data "aws_subnet" "default" {
  id = data.aws_subnet_ids.default.ids[0]
}

# Security Group para permitir acesso à instância EC2 e ao RDS
resource "aws_security_group" "allow_ec2_rds" {
  vpc_id = data.aws_vpc.default.id

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
    Name = "allow_ec2_rds"
  }
}

# RDS PostgreSQL
resource "aws_db_instance" "postgres" {
  engine            = "postgres"
  instance_class    = "db.t2.micro"
  allocated_storage = 20
  db_name           = var.db_name
  username          = var.db_username
  password          = var.db_password
  publicly_accessible = true
  vpc_security_group_ids = [aws_security_group.allow_ec2_rds.id]
  skip_final_snapshot = true

  tags = {
    Name = "Terraform-Postgres"
  }
}

# Output para capturar o endereço do RDS
output "rds_endpoint" {
  value = aws_db_instance.postgres.address
}

# Instância EC2
resource "aws_instance" "web" {
  ami           = "ami-09523541dfaa61c85"
  instance_type = "t2.micro"
  subnet_id     = data.aws_subnet.default.id
  security_groups = [aws_security_group.allow_ec2_rds.name]

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
