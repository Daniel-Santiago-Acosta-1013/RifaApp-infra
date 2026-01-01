variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "rifaapp"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "enable_nat_gateway" {
  type    = bool
  default = false
}

variable "db_engine" {
  type    = string
  default = "aurora-postgresql"
}

variable "db_engine_version" {
  type    = string
  default = null
}

variable "db_name" {
  type    = string
  default = "rifaapp"
}

variable "db_username" {
  type    = string
  default = "appuser"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_port" {
  type    = number
  default = 5432
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.medium"
}

variable "db_instance_count" {
  type    = number
  default = 1
}

variable "db_backup_retention" {
  type    = number
  default = 7
}

variable "db_skip_final_snapshot" {
  type    = bool
  default = true
}

variable "db_deletion_protection" {
  type    = bool
  default = false
}

variable "db_publicly_accessible" {
  type    = bool
  default = false
}

variable "db_apply_immediately" {
  type    = bool
  default = true
}

variable "lambda_runtime" {
  type    = string
  default = "nodejs18.x"
}

variable "lambda_handler" {
  type    = string
  default = "handler.handler"
}

variable "lambda_memory_size" {
  type    = number
  default = 256
}

variable "lambda_timeout" {
  type    = number
  default = 10
}

variable "lambda_log_retention" {
  type    = number
  default = 14
}

variable "api_stage_name" {
  type    = string
  default = "v1"
}

variable "enable_cors" {
  type    = bool
  default = true
}

variable "cors_allow_origins" {
  type    = list(string)
  default = ["*"]
}

variable "cors_allow_headers" {
  type    = list(string)
  default = ["*"]
}

variable "cors_allow_methods" {
  type    = list(string)
  default = ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"]
}
