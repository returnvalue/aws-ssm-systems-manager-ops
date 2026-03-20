# AWS provider configuration for LocalStack
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    apigateway     = "http://localhost:4566"
    cloudformation = "http://localhost:4566"
    cloudwatch     = "http://localhost:4566"
    dynamodb       = "http://localhost:4566"
    ec2            = "http://localhost:4566"
    es             = "http://localhost:4566"
    firehose       = "http://localhost:4566"
    iam            = "http://localhost:4566"
    kinesis        = "http://localhost:4566"
    lambda         = "http://localhost:4566"
    route53        = "http://localhost:4566"
    redshift       = "http://localhost:4566"
    s3             = "http://s3.localhost.localstack.cloud:4566"
    secretsmanager = "http://localhost:4566"
    ses            = "http://localhost:4566"
    sns            = "http://localhost:4566"
    sqs            = "http://localhost:4566"
    ssm            = "http://localhost:4566"
    stepfunctions  = "http://localhost:4566"
    sts            = "http://localhost:4566"
    elb            = "http://localhost:4566"
    elbv2          = "http://localhost:4566"
    rds            = "http://localhost:4566"
    autoscaling    = "http://localhost:4566"
    events         = "http://localhost:4566"
  }
}

# IAM Role: Identity for EC2 instances to communicate with Systems Manager (SSM)
resource "aws_iam_role" "ssm_role" {
  name = "ssm-managed-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = {
    Name        = "ssm-managed-role"
    Environment = "SysOps-Lab"
  }
}

# IAM Policy Attachment: Grants standard SSM core permissions
resource "aws_iam_role_policy_attachment" "ssm_managed_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# IAM Instance Profile: Connects the IAM role to EC2 instances
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ssm-managed-profile"
  role = aws_iam_role.ssm_role.name
}

# SSM Parameter: Centralized database endpoint configuration
resource "aws_ssm_parameter" "db_endpoint" {
  name        = "/sysops-lab/db/endpoint"
  description = "The database endpoint for the application"
  type        = "String"
  value       = "rds-db-instance.cluster-xyz.us-east-1.rds.amazonaws.com"

  tags = {
    Environment = "SysOps-Lab"
  }
}

# SSM Parameter: Secure storage for a simulated API key
resource "aws_ssm_parameter" "api_key" {
  name        = "/sysops-lab/api/key"
  description = "A simulated secure API key"
  type        = "SecureString"
  value       = "super-secret-api-key-12345"

  tags = {
    Environment = "SysOps-Lab"
  }
}

# Outputs: Key identifiers for testing the SSM operational automation
output "ssm_role_arn" {
  value = aws_iam_role.ssm_role.arn
}

output "db_endpoint_parameter" {
  value = aws_ssm_parameter.db_endpoint.name
}

output "api_key_parameter" {
  value = aws_ssm_parameter.api_key.name
}
