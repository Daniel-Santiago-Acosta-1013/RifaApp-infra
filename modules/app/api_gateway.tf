resource "aws_apigatewayv2_api" "http" {
  name          = "${local.name_prefix}-http-api"
  protocol_type = "HTTP"
  tags          = local.tags

  dynamic "cors_configuration" {
    for_each = var.enable_cors ? [1] : []
    content {
      allow_origins = var.cors_allow_origins
      allow_headers = var.cors_allow_headers
      allow_methods = var.cors_allow_methods
    }
  }
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.http.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.api.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "root" {
  api_id    = aws_apigatewayv2_api.http.id
  route_key = "ANY ${local.api_base_path}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_route" "proxy" {
  api_id    = aws_apigatewayv2_api.http.id
  route_key = "ANY ${local.api_base_path}/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_route" "explicit" {
  for_each = toset([
    "GET ${local.api_base_path}/health",
    "GET ${local.api_base_path}/version",
    "POST ${local.api_base_path}/migrations/run",
    "POST ${local.api_base_path}/auth/register",
    "POST ${local.api_base_path}/auth/login",
    "GET ${local.api_base_path}/docs",
    "GET ${local.api_base_path}/openapi.json",
    "GET ${local.api_base_path}/redoc",
    "GET ${local.api_base_path}/v2/raffles",
    "POST ${local.api_base_path}/v2/raffles",
    "GET ${local.api_base_path}/v2/raffles/{raffle_id}",
    "GET ${local.api_base_path}/v2/raffles/{raffle_id}/numbers",
    "POST ${local.api_base_path}/v2/raffles/{raffle_id}/reservations",
    "POST ${local.api_base_path}/v2/raffles/{raffle_id}/confirm",
    "POST ${local.api_base_path}/v2/raffles/{raffle_id}/release",
    "POST ${local.api_base_path}/v2/raffles/{raffle_id}/draw",
    "GET ${local.api_base_path}/v2/participants/{participant_id}/purchases",
  ])

  api_id    = aws_apigatewayv2_api.http.id
  route_key = each.value
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_stage" "main" {
  api_id      = aws_apigatewayv2_api.http.id
  name        = var.api_stage_name
  auto_deploy = true
  tags        = local.tags
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http.execution_arn}/*/*"
}
