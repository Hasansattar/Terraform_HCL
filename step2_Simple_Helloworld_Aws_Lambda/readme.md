# AWS Lambda and API Gateway with Terraform

To implement the same functionality using Terraform, you'll need to create an AWS Lambda function, an API Gateway, and deploy it with the correct permissions. Here’s a step-by-step guide to converting your AWS CDK code into Terraform.

## 1. Folder Structure



```python
├── main.tf # Main Terraform resources file 
├── provider.tf #  Configure the AWS provider
├── variables.tf # Variables used in the configuration (optional) 
├── outputs.tf # Outputs from the resources (optional) 
└── lambda 
  └── hello.js # Lambda handler code
```

## 2. Lambda Code (hello.js)
In the lambda folder, create hello.js file (this is the equivalent of your Lambda function in CDK):

```javascript
exports.handler = async function (event) {
    console.log("request:", JSON.stringify(event, undefined, 2));
    
    return {
        statusCode: 200,
        headers: { "Content-Type": "text/plain" },
        body: `Hello, Terraform! You've hit ${event.path}\n`
    };
};

```

## 3. Terraform Configuration
**main.tf**
This file will define your resources (Lambda function, API Gateway, and permissions).

```hcl
# Configure the AWS provider
provider "aws" {
  region = "us-east-1"  # Change to your desired region
}

# Create S3 bucket for Lambda code (optional)
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "my-lambda-bucket"
}

# Upload Lambda function code to S3 (optional)
resource "aws_s3_object" "lambda_zip" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "hello.zip"
  source = "lambda/hello.zip"  # Zip your Lambda function code before deploying
}

# Create the Lambda function
resource "aws_lambda_function" "hello_lambda" {
  function_name = "HelloFunction"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "hello.handler"
  runtime       = "nodejs18.x"

  filename = "lambda/hello.zip"  # Alternatively, use S3 bucket with source = aws_s3_object.lambda_zip.id

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

```

## 4. Explanation of Terraform Resources

- **AWS Provider:** Specifies the AWS region to deploy the resources.
- **S3 Bucket & Lambda Zip:** Optional, but you can use this to store the zipped Lambda function in S3 before deploying.
- **Lambda Function:** Deploys a Lambda function using the code in hello.zip.
- **IAM Role & Policy:** Grants the Lambda function the necessary permissions to write logs to CloudWatch.

**API Gateway:**
  - **API:** Creates an API Gateway with HTTP protocol.
  - **Integration:** Connects the API Gateway to the Lambda function.
  - **Route:** Sets up a default route to invoke the Lambda function.
  - **Stage:** Deploys the API Gateway with auto-deployment enabled.

**Lambda Permission:** Grants API Gateway the permission to invoke the Lambda function. 


## 5. Deploying with Terraform

**Terraform Help**

```bash
terraform -help
```

**1- Initialize Terraform:**

```bash
terraform init
```
**2- Validate Code:**
```bash
terraform validate
```

**3- Plan the infrastructure: This will show what changes Terraform will make.**

```bash
terraform plan
```

**4- Apply the configuration: Deploy the resources.**

```bash
terraform apply
```


**5- Destroy the resources.**

```bash
terraform destroy
```

Once deployed, Terraform will output the API Gateway URL. You can test it in your browser or with curl.

## 6. Testing the API
After deployment, the output will provide you with an API Gateway URL like:

```php
https://<api-id>.execute-api.<region>.amazonaws.com

```

Hit the URL, and you should see the response:
Hello, Terraform! You've hit /

## 7. Handling the Lambda Zip File

Terraform expects the Lambda code to be zipped. Before deploying, zip the **hello.js** file inside the **lambda** directory:

```bash
zip -r lambda/hello.zip lambda/hello.js

```
Now Terraform can deploy the zipped code to AWS.


