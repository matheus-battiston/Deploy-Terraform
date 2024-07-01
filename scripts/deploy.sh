#!/bin/bash

# Parar e remover o contêiner atual
docker stop myapp || true
docker rm myapp || true

# Fazer o pull da nova imagem do Docker Hub
docker pull matheusbattiston/account:latest

# Executar a nova imagem
docker run -d --name myapp -p 8080:8080 -e DATABASE_URL=jdbc:postgresql://postgres-db.cbgy4ye6ky3l.us-east-1.rds.amazonaws.com:5432/postgres matheusbattiston/account