# tf-gcp-infra

# Terraform Deployment for Google Cloud Platform Network

This Terraform deployment script automates the provisioning of network infrastructure on the Google Cloud Platform (GCP). It facilitates the creation of a Virtual Private Cloud (VPC) along with associated subnets and routes to support web application and database workloads.

## Prerequisites

Before running this Terraform script, ensure you have the following:

- **Terraform Installed**: Make sure you have Terraform installed on your local machine. You can download it from [here](https://www.terraform.io/downloads.html) and follow the installation instructions.

- **Google Cloud Platform Account**: You need to have a GCP account with appropriate permissions to create and manage resources.

- **GCP Credentials**: Set up GCP authentication by providing credentials such as service account key or user credentials with sufficient permissions to create and manage resources.

## Configuration

1. **Update Variables**: Modify the variables in the `terraform.tfvars` file according to your requirements. Ensure to provide values for variables such as `project_id`, `region`, `zone`, etc., as per your GCP setup.

2. **Review Configuration**: Take a look at the `main.tf` file to understand the resources being created and their configurations. You can customize these configurations based on your specific needs.

## Deployment Steps

Follow these steps to deploy the network infrastructure using Terraform:

1. **Initialize Terraform**: Run the following command to initialize Terraform in the project directory:
   ```bash
   terraform init

2. **Format Configuration Files**: Use the following command to automatically format your Terraform configuration files for consistency:

    ```bash
    terraform fmt

3. **Validate Configuration**: Validate the syntax and configuration of your Terraform files by running:

    ```bash
    terraform validate

4. **Review Execution Plan**: Generate an execution plan to preview the changes that will be made to your infrastructure:

    ```bash
    terraform plan

5. **Apply Configuration**: Apply the Terraform configuration to provision the infrastructure on GCP:

    ```bash
    terraform apply