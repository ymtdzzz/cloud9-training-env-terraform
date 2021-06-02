# TODO: make profile to custom variable
terraform {
    required_version = ">= 0.12.0"

    # When initialization, this block should be commented out.
    backend "s3" {
        bucket = "cloud9-training-env-terraform"
        key = "terraform.tfstate"
        region = "us-east-1"
        shared_credentials_file = "~/.aws/credentials"
        profile = "zeroc.rej.i"
    }
}

provider "aws" {
    region = "us-east-1"
    shared_credentials_file = "~/.aws/credentials"
    profile = "zeroc.rej.i"
}

resource "aws_s3_bucket" "terraform_state" {
    bucket = "cloud9-training-env-terraform"
    versioning {
        enabled = true
    }
}

data "aws_region" "current" {}

variable "name" {
    type = string
    default = "cloud9-training-env-terraform"
}

variable "azs" {
    default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "member_count" {
    type = number
    description = "The number of accounts to be created"
}

variable "cloud9_count" {
    type = number
    description = "The number of cloud9 environemnts to be created"
}

variable "owner_arn" {
    type = string
}

module "network" {
    source = "./network"
    name = var.name
    azs = var.azs
}

module "user" {
    source = "./user"
    user_count = var.member_count
    name = var.name
}


# Cloud9
resource "aws_cloudformation_stack" "cloud9" {
    count = var.cloud9_count
    
    name = "${var.name}-${count.index}"

    template_body = templatefile(
        "cloud9_stack.json",
        {
            resource_name = "cloud9"
            name = var.name
            count = count.index
            subnet_id = module.network.private_subnet_ids[0][0]
            owner_arn = var.owner_arn
        }
    )
}

output "encrypted_password" {
    value = module.user.encrypted_password
}

output "user" {
    value = module.user.user
}
