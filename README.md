# fiap-soat-tech-challenge-fase-3-db-terraform
Infra banco de dados gerenciáveis com Terraform

## Requirements
- AWS CLI
- Terraform CLI

## AWS Profiles

Obter profiles da AWS
```sh
aws configure list-profiles
```

Obter detalhes do profile da AWS atual
```sh
aws configure list
```

Caso não possuir nenhum profile, criar um novo utilizando suas credenciais da AWS.
```sh
aws configure --profile meu-novo-perfil
```

Definir um profile como ativo
```sh
export AWS_PROFILE=dequevedo-aws-profile
```

Obter o profile ativo
```sh
aws sts get-caller-identity --profile dequevedo-aws-profile
```

Atualizando o kubeconfig com as credenciais corretas
```sh
aws eks --region us-east-1 update-kubeconfig --name fiap-fase3-cluster --profile dequevedo-aws-profile
```

## Terraform

Inicializar o Terraform
```sh
terraform init
```

Verificar tudo que o Terraform fará
```sh
terraform plan
```

Aplicar o Terraform
```sh
terraform apply -auto-approve
```

Remover tudo que o Terraform criou
```sh
terraform destroy -auto-approve
```