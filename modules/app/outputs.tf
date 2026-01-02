output "api_url" {
  value = aws_apigatewayv2_stage.main.invoke_url
}

output "api_base_url" {
  value = "${aws_apigatewayv2_stage.main.invoke_url}${local.api_base_path}"
}

output "lambda_function_name" {
  value = aws_lambda_function.api.function_name
}

output "db_cluster_endpoint" {
  value = aws_rds_cluster.db.endpoint
}

output "db_reader_endpoint" {
  value = aws_rds_cluster.db.reader_endpoint
}

output "db_port" {
  value = var.db_port
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "frontend_bucket_name" {
  value = try(aws_s3_bucket.frontend[0].bucket, null)
}

output "frontend_distribution_id" {
  value = try(aws_cloudfront_distribution.frontend[0].id, null)
}

output "frontend_domain_name" {
  value = try(aws_cloudfront_distribution.frontend[0].domain_name, null)
}

output "frontend_url" {
  value = try("https://${aws_cloudfront_distribution.frontend[0].domain_name}", null)
}
