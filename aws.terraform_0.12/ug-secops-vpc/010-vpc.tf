# Store credentials in ~/.aws/credentials and declare invalid default profile to avoid mistakes
# [default]
# aws_access_key_id=AK-INVALID
# aws_secret_access_key=INVALIDKEY

# [secops]
# aws_access_key_id=AKIAIOSFODNN7EXAMPLE
# aws_secret_access_key=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
provider "aws" {
  version = "~> 3.0"
  profile = var.secops_iam_profile
  region  = var.secops_region
}

# We create a brand new "secops" VPC and subnets for this demonstration but you can of course use an existing VPC setup
# We enable DNS support to manage a private DNS zone in Route53 (very useful for TheHive to find its Cortex instance)
resource "aws_vpc" "secops-vpc" {
  cidr_block            = var.secops_vpc_cidr
  enable_dns_support    = true
  enable_dns_hostnames  = true

  tags = {
    Name = "secops-vpc"
  }
}

# We create the private DNS zone in Route53
resource "aws_route53_zone" "secops-private-dns-zone" {
  name = var.secops_r53_private_dns_zone_name
  comment = "Private DNS zone for the secops VPC"
  force_destroy = true

  vpc {
    vpc_id = aws_vpc.secops-vpc.id
  }
}

# We create two public subnets for our bastion host, NAT Gateway, Internet Gateway
# This will also be used for the ALB target groups
resource "aws_subnet" "secops-public-subnet-1" {
  cidr_block        = var.secops_public_subnet_1_cidr
  vpc_id            = aws_vpc.secops-vpc.id
  availability_zone = var.secops_az1

  tags = {
    Name = "secops-public-subnet-1"
  }
}

resource "aws_subnet" "secops-public-subnet-2" {
  cidr_block        = var.secops_public_subnet_2_cidr
  vpc_id            = aws_vpc.secops-vpc.id
  availability_zone = var.secops_az2

  tags = {
    Name = "secops-public-subnet-2"
  }
}

# We create two private subnets to host our instances
resource "aws_subnet" "secops-private-subnet-1" {
  cidr_block        = var.secops_private_subnet_1_cidr
  vpc_id            = aws_vpc.secops-vpc.id
  availability_zone = var.secops_az1

  tags = {
    Name = "secops-private-subnet-1"
  }
}

resource "aws_subnet" "secops-private-subnet-2" {
  cidr_block        = var.secops_private_subnet_2_cidr
  vpc_id            = aws_vpc.secops-vpc.id
  availability_zone = var.secops_az2

  tags = {
    Name = "secops-private-subnet-2"
  }
}

# We create a route table for our public subnet to be allowed to use the Internet Gateway
# and associate the route table with its subnets
resource "aws_route_table" "secops-public-route-table" {
  vpc_id = aws_vpc.secops-vpc.id

  tags = {
    Name = "secops-public-route-table"
  }
}

resource "aws_route_table_association" "secops-public-subnet-1-association" {
  route_table_id = aws_route_table.secops-public-route-table.id
  subnet_id      = aws_subnet.secops-public-subnet-1.id
}

resource "aws_route_table_association" "secops-public-subnet-2-association" {
  route_table_id = aws_route_table.secops-public-route-table.id
  subnet_id      = aws_subnet.secops-public-subnet-2.id
}

# We create a route table for our private subnets to be allowed to reach the public subnet 
# to use the NAT Gateway and associate the route table with both subnets
resource "aws_route_table" "secops-private-route-table" {
  vpc_id = aws_vpc.secops-vpc.id

  tags = {
    Name = "secops-private-route-table"
  }
}

resource "aws_route_table_association" "secops-private-subnet-1-association" {
  route_table_id = aws_route_table.secops-private-route-table.id
  subnet_id      = aws_subnet.secops-private-subnet-1.id
}

resource "aws_route_table_association" "secops-private-subnet-2-association" {
  route_table_id = aws_route_table.secops-private-route-table.id
  subnet_id      = aws_subnet.secops-private-subnet-2.id
}

# We create the Internet Gateway and add a route to it in the public route table
resource "aws_internet_gateway" "secops-vpc-igw" {
  vpc_id = aws_vpc.secops-vpc.id

  tags = {
    Name = "secops-vpc-igw"
  }
}

resource "aws_route" "secops-private-internet-gw-route" {
  route_table_id         = aws_route_table.secops-public-route-table.id
  gateway_id             = aws_internet_gateway.secops-vpc-igw.id
  destination_cidr_block = "0.0.0.0/0"
}

# We create a NAT Gateway within the public subnet
resource "aws_eip" "secops-nat-gw-eip" {
  vpc      = true

  tags = {
    Name = "secops-nat-gateway-eip"
  }
}

resource "aws_nat_gateway" "secops-nat-gw" {
  allocation_id = aws_eip.secops-nat-gw-eip.id
  subnet_id     = aws_subnet.secops-public-subnet-1.id

  tags = {
    Name = "secops-nat-gateway"
  }
}

# We create a route to allow the private subnets to reach the Internet through 
# the NAT Gateway in the public subnet 
resource "aws_route" "secops-public-subnet-nat-gw-route" {
  route_table_id         = aws_route_table.secops-private-route-table.id
  nat_gateway_id         = aws_nat_gateway.secops-nat-gw.id
  destination_cidr_block = "0.0.0.0/0"
}
