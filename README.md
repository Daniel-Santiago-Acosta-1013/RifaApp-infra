# RifaApp infra (Terraform)

Infraestructura en AWS para RifaApp con Terraform. Incluye red, base de datos Aurora,
Lambda y API Gateway, y un bootstrap para el bucket del estado.

## Alcance
- VPC con subnets publicas y privadas
- Aurora (PostgreSQL por defecto)
- Lambda dentro de la VPC
- HTTP API Gateway con integracion Lambda
- Bucket S3 para el estado de Terraform (versionado, cifrado, bloqueo publico)

## Estructura del repo
- `bootstrap/`: crea el bucket de estado en S3
- `networking.tf`, `rds.tf`, `lambda.tf`, `api_gateway.tf`: stack principal
- `backend.hcl.example`, `terraform.tfvars.example`: ejemplos de configuracion
- `../RifaApp-back/`: codigo del backend (FastAPI) y build de Lambda

## Requisitos
- Terraform >= 1.5
- AWS CLI configurado
- Credenciales con permisos para S3, VPC, RDS, Lambda, API Gateway, IAM y CloudWatch Logs
- Python 3.11 y Poetry (para construir el artefacto de Lambda en `RifaApp-back`)

## Instalacion local (macOS con Homebrew)
```
brew install awscli terraform poetry
```

## Configuracion de credenciales
Terraform usa las credenciales del AWS CLI o del entorno. Ejemplo:

```
export AWS_PROFILE=rifaapp-dev
export AWS_REGION=us-east-1
```

## Paso 1: bootstrap del estado
Crear el bucket del estado en S3:

```
terraform -chdir=bootstrap init
terraform -chdir=bootstrap apply -var="state_bucket_name=rifaapp-terraform-state-745819688993" -var="aws_region=us-east-1"
```

## Paso 2: configurar backend
Actualiza `backend.hcl.example` (bucket, key y region) y ejecuta:

```
terraform init -backend-config=backend.hcl.example -reconfigure
```

## Paso 3: variables del stack principal
Se creo `terraform.tfvars` desde el ejemplo y contiene `db_password`.
Este archivo esta en `.gitignore`. Cambia el password si es necesario.

## Paso 4: desplegar infraestructura
Antes de aplicar, construye el paquete de la Lambda en el repo del backend:

```
cd ../RifaApp-back
./scripts/build_lambda.sh
cd ../RifaApp-infra
```

Si usas otro path para el build, configura `lambda_source_dir`:
```
export TF_VAR_lambda_source_dir="/ruta/al/lambda_dist"
```

```
terraform plan
terraform apply
```

## Backend API
La API FastAPI y su documentacion viven en `../RifaApp-back/README.md`.

## Outputs principales
- `api_url`: URL del API Gateway
- `db_cluster_endpoint`: endpoint de escritura del cluster
- `db_reader_endpoint`: endpoint de lectura

## CI/CD (GitHub Actions)
Workflow manual en `/.github/workflows/deploy.yml` (solo `workflow_dispatch`).

Configura en GitHub (repo infra):
- Variables: `BACKEND_REPO` (owner/RifaApp-back), `BACKEND_REF` (opcional), `AWS_REGION`
- Secrets: `DB_PASSWORD` y credenciales AWS (`AWS_ROLE_ARN` para OIDC o `AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY`)

## Notas
- `db_password` se guarda en el estado de Terraform.
- `enable_nat_gateway` esta en `false` para reducir costos. Activala si Lambda necesita salida a internet.
- Para eliminar recursos: `terraform destroy` en la raiz. El bucket de estado se elimina aparte en `bootstrap/`.
