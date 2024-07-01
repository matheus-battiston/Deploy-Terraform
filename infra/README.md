Criar um arquivo "keysaws.pub" para acessar via ssh a ec2

Rodar o arquivo init.sql no banco

Executar o container docker na ec2 - Substituir {DNS_BANCO} pelo endpoint do banco de dados -

```sudo apt update```

```sudo apt install docker.io```

```docker run -d --name myapp -p 8080:8080 -e DATABASE_URL=jdbc:postgresql://{DNS_BANCO}:5432/postgres matheusbattiston/account```


