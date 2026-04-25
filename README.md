# AWS SSM Systems Manager Ops Lab

This lab demonstrates a core operational automation pattern for the **AWS SysOps Administrator Associate**: using Systems Manager to manage and configure instances at scale.

## Architecture Overview

The system implements a centralized management and configuration framework:

1.  **Managed Identity:** An IAM Role (`ssm-managed-role`) and Instance Profile grant EC2 instances the secure identity needed to communicate with Systems Manager.
2.  **Policy Enforcement:** The AWS-managed policy `AmazonSSMManagedInstanceCore` ensures that instances have the correct permissions for all standard SSM operations.
3.  **Centralized Configuration:** SSM Parameter Store provides a secure, hierarchical storage for configuration data (e.g., `/sysops-lab/db/endpoint`) and sensitive secrets (e.g., `/sysops-lab/api/key`).
4.  **Operational Scalability:** This architecture allows for remote command execution, automated patching, and inventory collection without requiring SSH access.

## Key Components

-   **IAM Role & Profile:** The foundational identity for managed instances.
-   **SSM Parameter Store:** The central repository for application parameters and secrets.
-   **Managed Policy:** Standardized permission set for Systems Manager core functionality.

## Prerequisites

-   [Terraform](https://www.terraform.io/downloads.html)
-   [LocalStack](https://localstack.cloud/)
-   [AWS CLI / awslocal](https://github.com/localstack/awscli-local)

## Deployment

1.  **Initialize and Apply:**
    ```bash
    terraform init
    terraform apply -auto-approve
    
```

## Verification & Testing

To test the operational automation components:

1.  **Verify SSM Parameters:**
    Retrieve the standard configuration parameter:
    ```bash
    awslocal ssm get-parameter --name /sysops-lab/db/endpoint
    aws ssm get-parameter --name /sysops-lab/db/endpoint
    
```
    Retrieve the secure API key:
    ```bash
    awslocal ssm get-parameter --name /sysops-lab/api/key --with-decryption
    aws ssm get-parameter --name /sysops-lab/api/key --with-decryption
    
```

2.  **Verify Managed Identity (Conceptual):**
    In a live AWS environment, an instance with the `ssm-managed-profile` would automatically appear in the SSM Managed Instances console.

3.  **Execute a Command (Conceptual):**
    You can use the SSM Run Command to execute scripts on managed instances:
    ```bash
    awslocal ssm send-command \
      --document-name "AWS-RunShellScript" \
      --targets "Key=tag:Name,Values=ssm-managed-instance" \
      --parameters 'commands=["echo hello world"]'
    aws ssm send-command \
      --document-name "AWS-RunShellScript" \
      --targets "Key=tag:Name,Values=ssm-managed-instance" \
      --parameters 'commands=["echo hello world"]'
    
```

## Cleanup

To tear down the infrastructure:
```bash
terraform destroy -auto-approve
```

---

💡 **Pro Tip: Using `aws` instead of `awslocal`**

If you prefer using the standard `aws` CLI without the `awslocal` wrapper or repeating the `--endpoint-url` flag, you can configure a dedicated profile in your AWS config files.

### 1. Configure your Profile
Add the following to your `~/.aws/config` file:
```ini
[profile localstack]
region = us-east-1
output = json
# This line redirects all commands for this profile to LocalStack
endpoint_url = http://localhost:4566
```

Add matching dummy credentials to your `~/.aws/credentials` file:
```ini
[localstack]
aws_access_key_id = test
aws_secret_access_key = test
```

### 2. Use it in your Terminal
You can now run commands in two ways:

**Option A: Pass the profile flag**
```bash
aws iam create-user --user-name DevUser --profile localstack
```

**Option B: Set an environment variable (Recommended)**
Set your profile once in your session, and all subsequent `aws` commands will automatically target LocalStack:
```bash
export AWS_PROFILE=localstack
aws iam create-user --user-name DevUser
```

### Why this works
- **Precedence**: The AWS CLI (v2) supports a global `endpoint_url` setting within a profile. When this is set, the CLI automatically redirects all API calls for that profile to your local container instead of the real AWS cloud.
- **Convenience**: This allows you to use the standard documentation commands exactly as written, which is helpful if you are copy-pasting examples from AWS labs or tutorials.
