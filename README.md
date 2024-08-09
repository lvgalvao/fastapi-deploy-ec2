# FastAPI Docker Project

Este projeto demonstra como configurar e rodar uma aplicação FastAPI simples dentro de um contêiner Docker. Ele inclui instruções completas para configurar uma instância EC2 na AWS, clonar o repositório, construir a imagem Docker, e rodar o contêiner.

## Pré-requisitos

- Uma conta AWS com permissões para criar instâncias EC2.
- Conhecimento básico de Docker e FastAPI.

## Passo a Passo

### 1. Configurar uma Instância EC2 na AWS

1. **Acesse o AWS Management Console**: Vá para [AWS Management Console](https://aws.amazon.com/console/) e faça login.
2. **Lance uma Instância EC2**:
   - **Escolha a AMI**: Selecione **Amazon Linux 2023**.
   - **Escolha o Tipo de Instância**: Selecione `t2.micro` (grátis elegível para o nível gratuito da AWS).
   - **Configurar Regras de Segurança**:
     - **SSH**: Porta 22.
     - **Adicionar Regra**:
       - **Tipo**: Custom TCP Rule.
       - **Porta**: 8000 (porta para FastAPI).
       - **Source**: Anywhere (0.0.0.0/0) para permitir acesso de qualquer lugar.
   - **Lance a Instância**: Revise e inicie a instância, escolhendo um par de chaves para acesso SSH.

### 2. Acessar a Instância EC2 via AWS Connect

Va até a aba 'EC2 Instance Connect' e clique em 'Connect'

### 3. Atualizar o Sistema

```bash
sudo dnf update -y
```

### 4. Instalar Git

```bash
sudo dnf install git -y
```

### 5. Clonar o Repositório

```bash
git clone https://github.com/lvgalvao/fastapi-deploy-ec2
ls
```

### 6. Instalar Docker

```bash
sudo dnf install docker -y
```

### 7. Iniciar e Habilitar o Docker

```bash
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
```

### 8. Reiniciar a Sessão SSH

```bash
exit
```

Reconecte-se à instância

```bash
cd fastapi-deploy-ec2
```

### 9. Construir a Imagem Docker

```bash
docker build -t fastapi-app .
```

### 10. Executar o Contêiner Docker

```bash
docker run -p 8000:8000 fastapi-app
```

### 11. Acessar a Aplicação FastAPI

No seu navegador, acesse o aplicativo usando o IP público da instância EC2 na porta 8000:

```
http://<seu-endereco-ip>:8000/
```

## Código de Exemplo FastAPI

Aqui está um exemplo simples de uma aplicação FastAPI que você pode incluir no seu projeto:

**`main.py`:**

```python
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"Hello": "World"}

@app.get("/items/{item_id}")
def read_item(item_id: int, q: str = None):
    return {"item_id": item_id, "q": q}
```

**`Dockerfile`:**

```dockerfile
# Use a imagem base Python 3.12.5 com Alpine 3.20
FROM python:3.12.5-slim-bullseye

# Defina o diretório de trabalho no contêiner
WORKDIR /app

# Copie o arquivo de requisitos para o contêiner
COPY requirements.txt .

# Instale as dependências do Python
RUN pip install --no-cache-dir -r requirements.txt

# Copie o restante da aplicação para o contêiner
COPY . .

# Exponha a porta que a aplicação utilizará
EXPOSE 8000

# Comando para rodar a aplicação FastAPI
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

**`requirements.txt`:**

```text
fastapi
uvicorn
```

### 12. Verificar Regras de Segurança (Se necessário)

Se você não conseguir acessar o aplicativo, verifique as **Regras de Segurança** para garantir que a porta 8000 está aberta.

### Considerações Finais

Com esses passos, você configurou uma instância EC2, clonou o repositório, construiu a imagem Docker, e executou uma aplicação FastAPI. Agora, você pode acessar e testar a aplicação no seu navegador.

---

Este `README.md` pode ser ajustado conforme necessário para atender às especificidades do seu projeto. Se precisar de mais alguma coisa ou tiver alguma dúvida, estou aqui para ajudar!