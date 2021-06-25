variable "name" {
    type = string
}

variable "azs" {
    type = list
}

variable "vpc_cidr" {
    default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
    # default = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
    default = ["10.0.0.0/24"]
}

# VPC
resource "aws_vpc" "this" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true

    tags = {
        Name = var.name
    }
}

# Public subnet
# This is used for NAT gateway
resource "aws_subnet" "publics" {
    count = length(var.public_subnet_cidrs)

    vpc_id = aws_vpc.this.id
    map_public_ip_on_launch = true

    availability_zone = var.azs[count.index]
    cidr_block = var.public_subnet_cidrs[count.index]

    tags = {
        Name = "${var.name}-public-${count.index}"
    }
}

resource "aws_internet_gateway" "this" {
    vpc_id = aws_vpc.this.id

    tags = {
        Name = var.name
    }
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.this.id

    tags = {
        Name = "${var.name}-public"
    }
}

resource "aws_route" "public" {
    destination_cidr_block = "0.0.0.0/0"
    route_table_id = aws_route_table.public.id
    gateway_id = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
    count = length(var.public_subnet_cidrs)

    subnet_id = element(aws_subnet.publics.*.id, count.index)
    route_table_id = aws_route_table.public.id
}

output "vpc_id" {
    value = aws_vpc.this.id
}

output "public_subnet_ids" {
    value = [aws_subnet.publics.*.id]
}
