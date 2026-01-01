output "api_url" {
  value = aws_apigatewayv2_stage.main.invoke_url
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
