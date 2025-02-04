
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

#### Public Route Table ####
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge (
    var.common_tags,
    var.public_route_table_tags,
    {
      Name = "${local.resource_name}-public" #expense-dev-public
    }
  )
}

#### Private Route Table ####
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge (
    var.common_tags,
    var.private_route_table_tags,
    {
      Name = "${local.resource_name}-private" #expense-dev-private
    }
  )
}

#### Database Route Table ####
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge (
    var.common_tags,
    var.database_route_table_tags,
    {
      Name = "${local.resource_name}-private" #expense-dev-database
    }
  )
}

#### Route Table Routes ####
resource "aws_route" "public_route" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id
}

resource "aws_route" "private_route_nat" {
  route_table_id = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}

resource "aws_route" "database_route_nat" {
  route_table_id = aws_route_table.database.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}

#### Route Table and Subnet Associations ####
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)     # Create one association per public subnet CIDR block in the list of public_subnet_cidrs
  route_table_id = aws_route_table.public.id
  subnet_id = aws_subnet.public[*].id        # * is a wildcard that tells Terraform to use all of the public subnet IDs here we have 2 public subnets
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)     # Create one association per private subnet CIDR block in the list of private_subnet_cidrs
  route_table_id = aws_route_table.private.id
  subnet_id = aws_subnet.private[*].id        # * is a wildcard that tells Terraform to use all of the public subnet IDs here we have 2 private subnets
}

resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidrs)     # Create one association per database subnet CIDR block in the list of database_subnet_cidrs
  route_table_id = aws_route_table.database.id
  subnet_id = aws_subnet.database[*].id        # * is a wildcard that tells Terraform to use all of the public subnet IDs here we have 2 database subnets
}
