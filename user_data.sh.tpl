#!/bin/bash
sudo dnf update -y
sudo dnf install git -y
git clone https://github.com/lvgalvao/fastapi-deploy-ec2 /home/ec2-user/fastapi-deploy-ec2
sudo dnf install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
cd /home/ec2-user/fastapi-deploy-ec2

# Configurar a variável de ambiente para o banco de dados
export DATABASE_URL="postgresql://${db_username}:${db_password}@${db_address}:5432/${db_name}"

# Construir a imagem Docker
docker build -t fastapi-app .

# Executar o contêiner Docker com a variável de ambiente configurada
docker run -p 80:80 -e DATABASE_URL="${DATABASE_URL}" fastapi-app
