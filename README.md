Terraform AWS VPC + 2 EC2 + Nginx Lab
This lab creates a custom AWS VPC with two public subnets, an Internet Gateway, a route table, a security group, and two Ubuntu EC2 instances running Nginx with a simple web page.
​

Architecture
Resources created by main.tf:
​
​

VPC: 10.0.0.0/16

2 public subnets:

10.0.1.0/24 in ap-south-1a

10.0.2.0/24 in ap-south-1b

Internet Gateway attached to the VPC

Public route table with 0.0.0.0/0 → Internet Gateway

Route table associations for both public subnets

Security Group dev-sg:

Inbound: SSH (22) from 0.0.0.0/0

Inbound: HTTP (80) from 0.0.0.0/0

Outbound: all traffic allowed

2 Ubuntu EC2 instances (t3.micro):

dev-server-1 in subnet 1

dev-server-2 in subnet 2

User data installs Nginx and writes a custom index.html

Prerequisites
Before running this lab:
​

AWS account and IAM user with permission to create VPC, subnets, EC2, security groups, etc.

AWS credentials configured locally (for example with aws configure).
​

Terraform installed (version 1.0+).
​

Git installed (for cloning from GitHub).

Files in this project
main.tf – Terraform configuration that defines the entire VPC + EC2 + Nginx setup.

README.md – This documentation.

Terraform configuration (main.tf)
main.tf contains:

Provider configuration:

AWS provider

Region: ap-south-1 (Mumbai)

Network layer:

VPC, subnets, Internet Gateway, route table, route associations, security group

Compute layer:

Two EC2 instances with user data that:

Runs apt-get update

Installs Nginx

Enables and starts Nginx

Writes a custom HTML message to /var/www/html/index.html

(Use the exact main.tf you already have in your project.)