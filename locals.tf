locals {
  name_prefix = "${var.project_name}-${var.environment}"
  lambda_source_dir = var.lambda_source_dir != "" ? var.lambda_source_dir : abspath("${path.module}/../RifaApp-back/lambda_dist")
  tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
    },
    var.tags
  )
}
