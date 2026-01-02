locals {
  name_prefix = "${var.project_name}-${var.environment}"
  lambda_source_dir = var.lambda_source_dir
  api_base_path = "/${trim(var.api_base_path, "/")}"
  frontend_bucket_name = var.frontend_bucket_name != "" ? var.frontend_bucket_name : "${local.name_prefix}-frontend-${data.aws_caller_identity.current.account_id}"
  tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
    },
    var.tags
  )
}
