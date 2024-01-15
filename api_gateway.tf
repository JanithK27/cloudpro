resource "aws_api_gateway_rest_api" "my_api" {
  name        = "MyAPI"
  description = "My API"
}

resource "aws_api_gateway_resource" "api_resource" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id   = aws_api_gateway_rest_api.my_api.root_resource_id
  path_part   = "hello"
}

resource "aws_api_gateway_method" "api_method" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.api_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.api_resource.id
  http_method = aws_api_gateway_method.api_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.my_lambda.invoke_arn
}

resource "aws_lambda_permission" "api_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.my_api.execution_arn}/*/GET/hello"
}

resource "aws_api_gateway_deployment" "my_api_deployment" {
  depends_on = [aws_api_gateway_integration.lambda_integration]

  rest_api_id = aws_api_gateway_rest_api.my_api.id
  stage_name  = "dev" # stage name
  lifecycle {
    create_before_destroy = true
  }

  instances = [
    {
      schema_version = 0
      attributes     = {
        created_date    = "2023-12-08T23:07:58Z",
        description     = "",
        execution_arn    = "arn:aws:execute-api:us-east-1:255945442255:uzcqojsnob/dev",
        id              = "2v861d",
        invoke_url      = "http://3.0.189.27/wordpress/",  # Updated URL
        rest_api_id     = aws_api_gateway_rest_api.my_api.id,
        stage_description = null,
        stage_name      = "dev",
        triggers        = null,
        variables       = null
      }
      sensitive_attributes = []
      private              = "bnVsbA=="
      dependencies         = [
        "aws_api_gateway_integration.lambda_integration",
        "aws_api_gateway_method.api_method",
        "aws_api_gateway_resource.api_resource",
        "aws_api_gateway_rest_api.my_api",
        "aws_iam_role.lambda_exec",
        "aws_lambda_function.my_lambda",
      ]
      create_before_destroy = true
    },
  ]
}

data "aws_region" "current" {}

output "hello_invoke_url" {
  value = "https://${aws_api_gateway_rest_api.my_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_api_gateway_deployment.my_api_deployment.stage_name}/hello"
}
