# Scalable Web Application Deployment on AWS with Terraform and CI/CD

---

## Table of Contents

* [1. Overview](#1-overview)
* [2. Architecture](#2-architecture)
* [3. AWS Services Used](#3-aws-services-used)
* [4. Terraform Modules](#4-terraform-modules)
* [5. Key Features](#5-key-features)
* [6. Prerequisites](#6-prerequisites)
* [7. Deployment Guide](#7-deployment-guide)
* [8. Project Outputs](#8-project-outputs)
* [9. Teardown](#9-teardown)
* [10. Future Enhancements](#10-future-enhancements)
* [11. Contributing](#11-contributing)
* [12. License](#12-license)
* [13. Author](#13-author)

---

## 1. Overview

This project demonstrates the provisioning of a robust, highly available, and scalable web application infrastructure on Amazon Web Services (AWS) using Terraform. It encompasses a complete environment including networking, compute resources managed by Auto Scaling, load balancing, custom domain mapping via DNS, and an automated Continuous Integration/Continuous Delivery (CI/CD) pipeline for seamless deployments from GitHub.

The infrastructure is designed for resilience and scalability, making it suitable for modern web applications. The use of Terraform ensures that the infrastructure is defined as code, promoting version control, repeatability, and collaboration.

## 2. Architecture

The infrastructure deploys a multi-tier web application architecture within a Virtual Private Cloud (VPC) spanning multiple Availability Zones for high availability.

**(Optional: You can replace this text block with an image of your architecture diagram once you create it. Tools like Draw.io, Lucidchart, or even simpler ASCII art generators can help.)**

              +---------------------+
              |     GitHub Repo     |
              | (adityar947/angular-|
              |    app-aws-ci/cd)   |
              +----------+----------+
                         |
                         | (Code Push)
                         v
              +----------+----------+
              |   AWS CodePipeline  |
              | (my-demo-pipeline)  |
              +----------+----------+
                         |
                         | (Build Stage)
                         v
              +----------+----------+
              |   AWS CodeBuild     |
              | (my-codebuild-project) |
              +----------+----------+
                         |
                         | (Deploy Stage)
                         v
              +----------+----------+
              |   S3 Artifact Store |
              | (my-artifact-bucket12345123) |
              +----------+----------+
                         |
                         | (Deployment Trigger)
                         v
    +----------------------------------------------------------------------------------------------------+
    |                                      AWS VPC (10.0.0.0/16)                                         |
    |                                                                                                    |
    |  +----------------------------------------------------------------------------------------------+  |
    |  | Public Subnet A (us-east-1a)          | Public Subnet B (us-east-1b)                         |  |
    |  | (10.0.1.0/24)                         | (10.0.2.0/24)                                        |  |
    |  +----------------------------------------------------------------------------------------------+  |
    |        ^ ^                                   ^ ^                                                   |
    |        | | (Traffic via Internet Gateway)    | |                                                   |
    |        | |                                   | |                                                   |
    |  +-----+-+-----------------------------------+--+-------------------------------------------------+ |
    |  |           AWS Route 53 Hosted Zone: "https://www.google.com/url?sa=E&amp;source=gmail&amp;q=example.com"                                            | |
    |  |           Alias Record: "www.example.com" -> ALB DNS                                         | |
    |  +----------------------------------------------------------------------------------------------+ |
    |                                ^                                                                   |
    |                                |                                                                   |
    |  +-----------------------------+-----------------------------------+-----------------------------+ |
    |  |                       Application Load Balancer (ALB)             |                             |
    |  |                       (my-alb)                                    |                             |
    |  |                       (Listening on Port 80, HTTP)                |                             |
    |  +-----------------------------+-----------------------------------+-----------------------------+ |
    |                                |                                                                   |
    |                                | (Traffic to Target Group)                                         |
    |                                v                                                                   |
    |  +-----------------------------+-----------------------------------+-----------------------------+ |
    |  |                       ALB Target Group                            |                             |
    |  |                       (my-new-tg)                                 |                             |
    |  |                       (Health Check: / on Port 80)                |                             |
    |  +-----------------------------+-----------------------------------+-----------------------------+ |
    |                                |                                                                   |
    |                                | (Targets: ASG instances)                                          |
    |                                v                                                                   |
    |  +----------------------------------------------------------------------------------------------+  |
    |  |                  Auto Scaling Group (ASG): "my-asg"                                          |  |
    |  |                  (Min: 1, Desired: 2, Max: 3)                                                |  |
    |  |                  (Instance Type: t3.micro)                                                   |  |
    |  |                  (AMI ID: ami-005fc0f236362e99f)                                            |  |
    |  |                  (Security Group: server1_sg)                                                |  |
    |  |                  (Attached to Public Subnets)                                                |  |
    |  |     +--------------------+      +--------------------+      +--------------------+           |  |
    |  |     | EC2 Instance (1/3) |      | EC2 Instance (2/3) |      | EC2 Instance (3/3) |           |  |
    |  |     +--------------------+      +--------------------+      +--------------------+           |  |
    |  +----------------------------------------------------------------------------------------------+  |
    +----------------------------------------------------------------------------------------------------+
                         
## 3. AWS Services Used

* Amazon VPC: Secure and isolated network environment. 
* Amazon EC2: Virtual servers for running the application. 
* Auto Scaling Group (ASG): Automatically adjusts EC2 capacity to maintain performance and cost efficiency. 
* Application Load Balancer (ALB): Distributes incoming application traffic across multiple targets. 
* AWS IAM: Manages access to AWS services and resources, including EC2 instance profiles. 
* AWS Security Groups: Acts as virtual firewalls to control traffic to instances. 
* Amazon Route 53: Scalable cloud Domain Name System (DNS) web service for domain registration and routing traffic. 
* AWS CodePipeline: Automates the release pipelines for fast and reliable application and infrastructure updates. 
* AWS CodeBuild: Compiles source code, runs tests, and produces deployable software packages. 
* Amazon S3: Used as an artifact store for CodePipeline. 
* AWS Secrets Manager: Securely stores and retrieves sensitive information (e.g., GitHub Personal Access Token). 

## 4. Terraform Modules

This project is structured using Terraform modules to promote reusability, maintainability, and organization.

* `vpc`: Defines the Virtual Private Cloud (VPC), public subnets, and an Internet Gateway. 
* `iam`: Creates IAM roles and instance profiles necessary for EC2 instances. 
* `security_groups`: Manages various security groups (e.g., for SSH, HTTP, HTTPS, application servers, ALB). 
* `ec2`: Provisions individual EC2 instances (used for attaching to the target group for demonstration purposes, though the ASG also uses similar EC2 configurations). 
* `target_group`: Sets up the ALB Target Group for routing traffic to backend instances. 
* `alb`: Deploys the Application Load Balancer and its listeners. 
* `asg`: Configures the Auto Scaling Group for dynamic scaling of application instances. 
* `route53`: Manages DNS records to point a custom domain to the ALB. 
* `codepipeline`: Sets up the CI/CD pipeline integrated with GitHub and AWS CodeBuild. 

## 5. Key Features

* **Infrastructure as Code (IaC):** Entire infrastructure defined, provisioned, and managed using Terraform.
* **High Availability:** Deploys resources across multiple AWS Availability Zones.
* **Scalability:** Leverages Auto Scaling Groups to automatically scale compute capacity based on demand.
* **Load Balancing:** Distributes incoming web traffic efficiently using an Application Load Balancer.
* **Custom Domain:** Configures Route 53 to map a custom domain to the deployed ALB.
* **Automated CI/CD:** Implements a full CodePipeline for automated builds and deployments from GitHub, ensuring rapid and consistent releases.
* **Modular Design:** Organized into reusable Terraform modules for clarity and ease of extension.
* **Secure Access:** Utilizes Security Groups to control network traffic and IAM roles for secure instance permissions.

## 6. Prerequisites

To deploy this infrastructure, you will need:

* **AWS Account:** An active AWS account with appropriate permissions to create the resources.
* **AWS CLI:** Configured locally with credentials for your AWS account.
    * Ensure your default region is set (e.g., `us-east-1`).
* **Terraform:** [Terraform CLI](https://www.terraform.io/downloads.html) (v1.0.0 or higher recommended) installed locally.
* **GitHub Repository:**
    * A GitHub repository (e.g., `adityar947/angular-app-aws-cicd`) containing your application code. 
    * A Personal Access Token (PAT) for GitHub.
* **AWS Secrets Manager Secret:** Your GitHub Personal Access Token **must be stored in AWS Secrets Manager** with the name `github-token` in the same region where you plan to deploy.
    * `aws secretsmanager create-secret --name github-token --secret-string "YOUR_GITHUB_PAT"`
* **Registered Domain (Optional but Recommended):** If you want to use the Route 53 functionality, you need a domain registered with Route 53 (e.g., `example.com`). The `www.example.com` record will be created within this hosted zone.

## 7. Deployment Guide

Follow these steps to deploy the infrastructure:

1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/adityar947/scalable-aws-webapp-terraform.git
    cd scalable-aws-webapp-terraform
    ```

2.  **Initialize Terraform:**
    Navigate to the root of the project (`TRENDS_TF` directory where `main.tf` is located) and initialize Terraform providers and modules.
    ```bash
    terraform init
    ```

3.  **Review the Plan:**
    
    ```bash
    terraform plan
    ```

5.  **Apply the Configuration:**
    If the plan looks correct, apply the changes to provision the infrastructure. Type `yes` when prompted.
    ```bash
    terraform apply
    ```
    This process can take several minutes as AWS provisions resources.

6.  **Verify Deployment:**
    Once `terraform apply` completes successfully, you can verify the deployment:
    * Check the AWS Console for created VPC, EC2 instances, ALB, ASG, CodePipeline, etc.
    * Use the `terraform output` command to retrieve the ALB DNS name or the website URL.

## 8. Project Outputs

After a successful `terraform apply`, you can retrieve important information about your deployed infrastructure using `terraform output`. Key outputs will include:

* **ALB DNS Name:** The DNS endpoint for your Application Load Balancer.
* **Website URL:** The `www` domain name configured in Route 53, pointing to your ALB.

To view all outputs:
```bash
terraform output
```

Example:
```bash
alb_dns_name = "my-alb-123456789.us-east-1.elb.amazonaws.com"
website_url  = "http://www.example.com" # This will be your actual domain
```
9. Teardown
To destroy all the AWS resources provisioned by this Terraform configuration, run the following command:

```bash
terraform destroy
```

Review the proposed destruction plan and type yes when prompted to confirm. Be extremely cautious with this command, as it will permanently delete all resources and data.

10. Future Enhancements
Database Integration: Add a managed database service like RDS (Relational Database Service) for data persistence.
HTTPS/SSL: Implement SSL/TLS certificates using AWS Certificate Manager (ACM) and configure HTTPS listeners on the ALB.
Monitoring & Logging: Integrate with AWS CloudWatch for metrics and logs, and potentially implement centralized logging solutions (e.g., ELK stack).
WAF (Web Application Firewall): Protect the application from common web exploits.
Private Subnets: Introduce private subnets for database instances and other backend services, and use NAT Gateways for outbound internet access from private subnets.
Blue/Green Deployments: Enhance the CI/CD pipeline for advanced deployment strategies.
Environment Variables: Externalize application-specific environment variables for better management.
Cost Optimization: Implement EC2 Spot Instances for non-critical workloads, or explore Graviton instances.
Terraform Cloud/Atlantis: Integrate with a remote state management and collaboration tool for team environments.
Custom AMI: Use a custom AMI pre-configured with your application dependencies to speed up instance launch times.
11. Contributing
Feel free to fork this repository, open issues, or submit pull requests. Contributions are welcome!

12. License
This project is open-source and available under the MIT License.

13. Author |
Aditya Ranjan |
DevOps Engineer | Automation Enthusiast |
[🔗 LinkedIn](https://www.linkedin.com/in/adityar947/)
[🔗 GitHub Profile](https://github.com/adityar947)

### Suggestions for Improvement:

Your current setup is a great foundation! Here are some suggestions to make it even more robust, secure, and production-ready:

1.  **State Management (Crucial!):**
    * **Remote Backend:** Currently, your `terraform.tfstate` file is local. In a real-world scenario, you *must* use a remote backend (like S3 with DynamoDB locking) to store your Terraform state. This prevents state corruption, enables team collaboration, and keeps sensitive state data out of local machines.
        ```terraform
        terraform {
          backend "s3" {
            bucket         = "your-terraform-state-bucket" # Create this bucket manually once
            key            = "trends-tf/terraform.tfstate"
            region         = "us-east-1"
            dynamodb_table = "your-terraform-lock-table" # Create this DynamoDB table manually once
            encrypt        = true
          }
        }
        ```
    * **State Locking:** The DynamoDB table is crucial for state locking, preventing multiple people from running `terraform apply` concurrently and corrupting the state file.

2.  **Input Validation:**
    * Add `validation` blocks to your `variable` definitions in `variables.tf` files. This ensures that users provide valid inputs, preventing common deployment errors.
        ```terraform
        variable "cidr_block" {
          description = "The CIDR block for the VPC."
          type        = string
          validation {
            condition     = can(cidrhost(var.cidr_block, 0)) && cidrnetmask(var.cidr_block) != ""
            error_message = "The VPC CIDR block must be a valid CIDR."
          }
        }
        ```

3.  **Output More Variables from Modules:**
    * Ensure each module outputs all the necessary resource attributes that might be consumed by other modules or useful for post-deployment verification. For instance, the `vpc` module could output `public_subnet_ids` as a list, which you already do but ensure consistency.

4.  **Use `data` sources for AMIs:**
    * Instead of hardcoding `ami-005fc0f236362e99f` (which is region-specific and might become outdated), use a `data` source to dynamically fetch the latest Amazon Linux 2 or a specific Ubuntu AMI.
        ```terraform
        data "aws_ami" "amazon_linux_2" {
          most_recent = true
          owners      = ["amazon"]
          filter {
            name   = "name"
            values = ["amzn2-ami-hvm-*-x86_64-gp2"]
          }
          filter {
            name   = "virtualization-type"
            values = ["hvm"]
          }
        }

        # Then reference it like: var.ami_id = data.aws_ami.amazon_linux_2.id
        ```
        
5.  **Environment Specifics:**
    * Consider using workspaces (`terraform workspace new dev` / `terraform workspace new prod`) or dedicated environment folders (`env/dev/main.tf`, `env/prod/main.tf`) to manage different environments (development, staging, production) with varying configurations (e.g., instance types, ASG sizes, domain names).

6.  **Secret Management Best Practices:**
    * You are already using AWS Secrets Manager for the GitHub token, which is excellent. Ensure you educate users on how to populate this secret.

7.  **CodeDeploy and Application Deployment:**
    * While Terraform provisions the CodeDeploy resources, the actual application deployment process (e.g., `appspec.yml`) is usually handled by your application repository. Make sure your example application (if any) is structured to work with CodeDeploy.
    * Consider adding a simple placeholder `appspec.yml` in your GitHub repo for the CodeDeploy to pick up.

8.  **Error Handling and Robustness:**
    * For production-grade deployments, consider adding `depends_on` explicit dependencies if implicit dependencies aren't sufficient, though Terraform usually handles this well.
    * Look into `count` or `for_each` for creating multiple similar resources (e.g., if you had many more distinct security groups or listeners) to reduce repetition.

9.  **HTTPS for ALB:**
    * Your current ALB listener is HTTP. For a production web application, you'll definitely want to implement HTTPS using AWS Certificate Manager (ACM) and configure the ALB to use an SSL certificate. This will require another module or additional resources in your `alb` module.

10. **Networking Detail:**
    * While you have public subnets, for more complex applications, you might introduce private subnets, NAT Gateways, VPC Endpoints, and stricter routing.

By implementing these improvements, your Terraform project will become even more robust, scalable, and aligned with industry best practices, making it even more impressive to recruiters.
