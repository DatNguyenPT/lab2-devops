# Backend
module "pre-backend" {
  source = "./backend/pre-setup"
}

module "backend" {
  source = "./backend"
}

#####################################################################################################
# VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "nhom1-vpc"
  cidr = "10.0.0.0/16"

  azs              = ["us-east-1a"]
  private_subnets  = ["10.0.1.0/24"]
  public_subnets   = ["10.0.101.0/24"]

  # Enable NAT Gateway for private subnets (set to true if you need private instances to access internet)
  enable_nat_gateway = true
  single_nat_gateway = true

  # Enable DNS hostnames and support
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Add VPC endpoints if needed
  enable_vpn_gateway = false

  # Tags
  tags = {
    Terraform   = "true"
    Environment = "development"
  }

  # Subnet tags
  public_subnet_tags = {
    Type = "Public"
  }

  private_subnet_tags = {
    Type = "Private"
  }
}

#####################################################################################################
# Remove these modules - they conflict with the VPC module:
# - module "eip"
# - module "igw" 
# - module "nat-gw"
# - module "public-rtb"
# - module "private-rtb"

#####################################################################################################
# Security Groups
module "public-sg" {
  source = "./modules/sg"

  name   = "public-sg"
  vpc_id = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "Allow SSH from my IP"
      cidr_blocks = "192.168.101.0/24"
    }
  ]
}

module "private-sg" {
  source = "./modules/sg"

  name   = "private-sg"
  vpc_id = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      description              = "Allow SSH from public EC2"
      cidr_blocks              = null
      source_security_group_id = module.public-sg.security_group_id
    }
  ]
}

#####################################################################################################
# EC2 Instances
module "public-ec2" {
  source              = "./modules/ec2"
  vpc_id              = module.vpc.vpc_id
  ami_id              = "ami-0a7d80731ae1b2435"
  instance_type       = "t2.small"
  key_name            = "instance-keypair"
  subnet_id           = module.vpc.public_subnets[0]
  security_group_id   = module.public-sg.security_group_id
  instance_name       = "nhom1-public-ec2"
  volume_size         = 10

  tags = {
    Environment = "dev"
  }
}

module "private-ec2" {
  source              = "./modules/ec2"
  vpc_id              = module.vpc.vpc_id
  ami_id              = "ami-0a7d80731ae1b2435"
  instance_type       = "t2.small"
  key_name            = "instance-keypair"
  subnet_id           = module.vpc.private_subnets[0]
  security_group_id   = module.private-sg.security_group_id
  instance_name       = "nhom1-private-ec2"
  volume_size         = 10

  tags = {
    Environment = "dev"
  }
}

#####################################################################################################
# Outputs (optional - to see the created resources)
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnets
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = module.vpc.igw_id
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs"
  value       = module.vpc.natgw_ids
}