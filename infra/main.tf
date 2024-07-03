provider "aws" {
  region = "us-east-1"
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}

resource "aws_key_pair" "deployer-key" {
  key_name   = "my-existing-key"
  public_key = file("keysaws.pub")
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

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

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.subnet_b.id
  route_table_id = aws_route_table.main.id
}

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

resource "aws_instance" "example" {
  ami                         = "ami-007855ac798b5175e" # Ubuntu 22.04 LTS
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.deployer-key.key_name
  subnet_id                   = aws_subnet.subnet_a.id
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id, aws_security_group.allow_postgres.id]
  associate_public_ip_address = true

  iam_instance_profile = "LabInstanceProfile"

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update
              sudo apt install -y docker.io
              echo "export DATABASE_URL=jdbc:postgresql://${aws_db_instance.postgres.address}:5432/postgres" >> /etc/profile
              source /etc/profile
              sudo apt-get update
              sudo apt-get install ruby-full ruby-webrick wget -y
              cd /tmp
              wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/releases/codedeploy-agent_1.3.2-1902_all.deb
              mkdir codedeploy-agent_1.3.2-1902_ubuntu22
              dpkg-deb -R codedeploy-agent_1.3.2-1902_all.deb codedeploy-agent_1.3.2-1902_ubuntu22
              sed 's/Depends:.*/Depends:ruby3.0/' -i ./codedeploy-agent_1.3.2-1902_ubuntu22/DEBIAN/control
              dpkg-deb -b codedeploy-agent_1.3.2-1902_ubuntu22/
              sudo dpkg -i codedeploy-agent_1.3.2-1902_ubuntu22.deb
              sudo systemctl list-units --type=service | grep codedeploy
              sudo docker pull matheusbattiston/account:latest
              docker run -d --name myapp -p 8080:8080 -e DATABASE_URL=jdbc:postgresql://${aws_db_instance.postgres.address}:5432/postgres matheusbattiston/account
              EOF

  tags = {
    Name = "ExampleInstance"
    CodeDeploy = "ExampleApp" # Adiciona a tag CodeDeploy para associar ao grupo de implementação
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "my-db-subnet-group"
  subnet_ids = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]

  tags = {
    Name = "My DB Subnet Group"
  }
}

resource "aws_db_instance" "postgres" {
  identifier              = "postgres-db"
  allocated_storage       = 10
  engine                  = "postgres"
  engine_version          = "14"
  instance_class          = "db.t3.micro"
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.main.id
  vpc_security_group_ids  = [aws_security_group.allow_postgres.id]
  skip_final_snapshot     = true
  publicly_accessible     = true
}

resource "aws_codedeploy_app" "example" {
  name = "AccountCodeDeploy"
  compute_platform = "Server"
}

# Obtém dinamicamente o ID da conta AWS
data "aws_caller_identity" "current" {}

resource "aws_codedeploy_deployment_group" "example" {
  app_name              = aws_codedeploy_app.example.name
  deployment_group_name = "AccountDeploymentGroup"
  service_role_arn      = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  deployment_style {
    deployment_type = "IN_PLACE"
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
  }
  ec2_tag_set {
    ec2_tag_filter {
      key   = "CodeDeploy"
      value = "ExampleApp"
      type  = "KEY_AND_VALUE"
    }
  }
}

resource "null_resource" "db_setup" {
  depends_on = [aws_db_instance.postgres]

  provisioner "local-exec" {
    command = "psql -h ${aws_db_instance.postgres.address} -p 5432 -U ${var.db_username} -d postgres -f init.sql"

    environment = {
      PGPASSWORD = var.db_password
    }
  }
}

output "ec2_public_ip" {
  value = aws_instance.example.public_dns
}

output "rds_endpoint" {
  value = aws_db_instance.postgres.endpoint
}