# RifaApp infra (Terraform + Terragrunt)

Infraestructura en AWS para RifaApp con Terraform. Incluye red, base de datos Aurora,
Lambda, API Gateway, frontend en S3 + CloudFront, y un bootstrap para el bucket del estado.

## Alcance
- VPC con subnets publicas y privadas
- Aurora (PostgreSQL por defecto)
- Lambda dentro de la VPC
- HTTP API Gateway con integracion Lambda
- S3 + CloudFront para frontend (SPA)
- Bucket S3 para el estado de Terraform (versionado, cifrado, bloqueo publico)

## Estructura del repo
- `bootstrap/`: crea el bucket de estado en S3
- `modules/app/`: stack principal (VPC, RDS, Lambda, API Gateway)
- `modules/frontend/`: stack del frontend (S3 + CloudFront)
- `envs/dev/`: variables y Terragrunt del entorno
- `envs/frontend/`: Terragrunt para frontend (estado separado)
- `backend.hcl.example`, `root.hcl`: referencia y backend real de Terragrunt
- `../RifaApp-back/`: codigo del backend (FastAPI) y build de Lambda

## Requisitos
- Terraform >= 1.5
- Terragrunt >= 0.96
- AWS CLI configurado
- Credenciales con permisos para S3, VPC, RDS, Lambda, API Gateway, IAM y CloudWatch Logs
- Python 3.11 y Poetry (para construir el artefacto de Lambda en `RifaApp-back`)

## Instalacion local (macOS con Homebrew)
```
brew install awscli terraform terragrunt poetry
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
terragrunt --working-dir bootstrap init
terragrunt --working-dir bootstrap apply -var="state_bucket_name=rifaapp-terraform-state-745819688993" -var="aws_region=us-east-1"
```

## Paso 2: configurar backend
Actualiza `backend.hcl.example` (referencia) y `root.hcl` (backend real)
con el bucket, key y region del estado.

## Paso 3: variables del stack principal
Si quieres usar archivo local, copia `envs/dev/terraform.tfvars.example` a
`envs/dev/terraform.tfvars` y agrega `db_password`. Este archivo esta en `.gitignore`.
Alternativa: exporta `TF_VAR_db_password` en tu shell.

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
terragrunt --working-dir envs/dev plan
terragrunt --working-dir envs/dev apply
```

## Frontend (S3 + CloudFront)
El frontend se aplica con Terragrunt en `envs/frontend` (estado separado) para evitar
que el deploy del backend modifique recursos del frontend.

```
terragrunt --working-dir envs/frontend apply
```

## Backend API
La API FastAPI y su documentacion viven en `../RifaApp-back/README.md`.

## Outputs principales
- `api_url`: URL del API Gateway (stage)
- `api_base_url`: URL base del API (incluye `/rifaapp`)
- `db_cluster_endpoint`: endpoint de escritura del cluster
- `db_reader_endpoint`: endpoint de lectura
- `frontend_bucket_name`: bucket S3 del frontend
- `frontend_distribution_id`: ID de CloudFront
- `frontend_url`: URL publica de CloudFront

## CI/CD (GitHub Actions)
Workflow manual en `/.github/workflows/deploy.yml` (solo `workflow_dispatch`), usa Terragrunt.
Workflow manual en `/.github/workflows/migrate.yml` para ejecutar migraciones via API.
El deploy del frontend corre desde el repo `RifaApp-front` y aplica Terragrunt en `envs/frontend`.

Configura en GitHub (repo infra):
- Variables: `BACKEND_REPO` (owner/RifaApp-back), `BACKEND_REF` (opcional), `AWS_REGION`, `API_BASE_PATH` (por defecto `rifaapp`)
- Secrets: `DB_PASSWORD` y credenciales AWS (`AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY`)

## Notas
- `db_password` se guarda en el estado de Terraform.
- `enable_nat_gateway` esta en `false` para reducir costos. Activala si Lambda necesita salida a internet.
- Para eliminar recursos: `terragrunt --working-dir envs/dev destroy`. El bucket de estado se elimina aparte en `bootstrap/`.
