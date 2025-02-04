
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(      # Merge all maps into one
    var.common_tags,
    var.vpc_tags,
    {
      Name = local.resource_name
    }
  )
}

resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.main.id      # Attach the IGW to the VPC

    tags = merge(           # Merge all maps into one
        var.common_tags,
        var.igw_tags,
        {
        Name = local.resource_name
        }
    )
}

### Public Subnets ###
resource "aws_subnet" "public" {  # first name is public[0], second name is public[1], etc.
  count = length(var.public_subnet_cidrs)  # Create one public subnet per public subnet CIDR block in the list of public_subnet_cidrs
  availability_zone = local.az_names[count.index]
  map_public_ip_on_launch = true
  vpc_id = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]  # Use the CIDR block from the list of public_subnet_cidrs for this subnet creation iteration

  tags = merge(      # Merge all maps into one
    var.common_tags,
    var.public_subnet_cidrs_tags,
    {
      Name = "${local.resource_name}-public-${local.az_names[count.index]}" # Use the AZ name from the list of az_names for this subnet creation iteration to create a unique name for this subnet resource instance
    }
  )
}

### Private Subnets ###
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)  # Create one public subnet per public subnet CIDR block in the list of public_subnet_cidrs
  availability_zone = local.az_names[count.index]
  vpc_id = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]  # Use the CIDR block from the list of public_subnet_cidrs for this subnet creation iteration

  tags = merge(      # Merge all maps into one
    var.common_tags,
    var.private_subnet_cidrs_tags,
    {
      Name = "${local.resource_name}-private-${local.az_names[count.index]}" # Use the AZ name from the list of az_names for this subnet creation iteration to create a unique name for this subnet resource instance
    }
  )
}

### Database Subnets ###
resource "aws_subnet" "database" {
  count = length(var.database_subnet_cidrs)  # Create one public subnet per public subnet CIDR block in the list of public_subnet_cidrs
  availability_zone = local.az_names[count.index]
  vpc_id = aws_vpc.main.id
  cidr_block = var.database_subnet_cidrs[count.index]  # Use the CIDR block from the list of public_subnet_cidrs for this subnet creation iteration

  tags = merge(      # Merge all maps into one
    var.common_tags,
    var.database_subnet_cidrs_tags,
    {
      Name = "${local.resource_name}-database-${local.az_names[count.index]}" # Use the AZ name from the list of az_names for this subnet creation iteration to create a unique name for this subnet resource instance
    }
  )
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  subnet_id = aws_subnet.public[0].id
  allocation_id = aws_eip.nat.id

  tags = merge(      # Merge all maps into one
    var.common_tags,
    var.nat_gateway_tags,
    {
      Name = "${local.resource_name}"    #expense-dev
    }
  )
  depends_on = [aws_internet_gateway.gw]  # this is explicitly telling Terraform that the NAT Gateway resource depends on the Internet Gateway resource
}