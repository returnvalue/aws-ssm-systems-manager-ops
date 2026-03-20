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
    ```
    Retrieve the secure API key:
    ```bash
    awslocal ssm get-parameter --name /sysops-lab/api/key --with-decryption
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
    ```

## Cleanup

To tear down the infrastructure:
```bash
terraform destroy -auto-approve
```
