# # Configure the AWS provider
# provider "aws" {
#   region = "us-east-1"  # Change to your desired region
# }



# Create the Lambda function
resource "aws_lambda_function" "hello_lambda" {
  function_name = "HelloFunction"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "hello.handler"
  runtime       = "nodejs18.x"

  filename = "lambda/hello.zip"  

  environment {
    variables = {
      LOG_LEVEL = "INFO"
    }
  }
}

# Create an IAM role for Lambda to allow it to write logs to CloudWatch
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Attach a policy to the Lambda IAM role for logging permissions
resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Create an API Gateway REST API to expose the Lambda function
resource "aws_apigatewayv2_api" "lambda_api" {
  name          = "LambdaAPI"
  protocol_type = "HTTP"
}

# Create API Gateway integration for Lambda
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id             = aws_apigatewayv2_api.lambda_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.hello_lambda.arn
  payload_format_version = "2.0"
}

# Create an API Gateway route to call the Lambda function
resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.lambda_api.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Deploy the API Gateway
resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.lambda_api.id
  name        = "$default"
  auto_deploy = true
}

# Grant permission to API Gateway to invoke the Lambda function
resource "aws_lambda_permission" "apigw_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda_api.execution_arn}/*"
}
