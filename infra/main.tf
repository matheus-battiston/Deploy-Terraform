provider "aws" {
  region = "us-east-1"
}

# Cria um par de chaves SSH usando uma chave pública existente
resource "aws_key_pair" "deployer-key" {
  key_name   = "my-existing-key"
  public_key = file("keysaws.pub")
}

# Cria uma VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# Cria sub-redes em diferentes zonas de disponibilidade
resource "aws_subnet" "subnet_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "subnet_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

# Cria um Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

# Cria uma Tabela de Rotas
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

# Associa a Tabela de Rotas às Sub-redes
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.subnet_b.id
  route_table_id = aws_route_table.main.id
}

# Cria um grupo de segurança para a instância EC2
resource "aws_security_group" "allow_ssh" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Cria um grupo de segurança para o RDS
resource "aws_security_group" "allow_postgres" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Acesso público, ajuste conforme necessário
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Cria uma instância EC2
resource "aws_instance" "example" {
  ami           = "ami-007855ac798b5175e" # Ubuntu 22.04 LTS
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.deployer-key.key_name
  subnet_id       = aws_subnet.subnet_a.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id, aws_security_group.allow_postgres.id]
  associate_public_ip_address = true

  iam_instance_profile = "LabInstanceProfile"
  tags = {
    Name = "ExampleInstance"
  }
}

# Cria um grupo de sub-redes para o RDS
resource "aws_db_subnet_group" "main" {
  name       = "my-db-subnet-group"
  subnet_ids = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]

  tags = {
    Name = "My DB Subnet Group"
  }
}

# Cria uma instância RDS PostgreSQL
resource "aws_db_instance" "postgres" {
  identifier              = "postgres-db"
  allocated_storage       = 10
  engine                  = "postgres"
  engine_version          = "14"
  instance_class          = "db.t3.micro"
  username                = "postgres"
  password                = "postgres"
  db_subnet_group_name    = aws_db_subnet_group.main.id
  vpc_security_group_ids  = [aws_security_group.allow_postgres.id]
  skip_final_snapshot     = true
  publicly_accessible     = true
}

output "ec2_public_ip" {
  value = aws_instance.example.public_dns
}

output "rds_endpoint" {
  value = aws_db_instance.postgres.endpoint
}