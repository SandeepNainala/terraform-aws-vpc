
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
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)  # Create one public subnet per public subnet CIDR block in the list of public_subnet_cidrs
  availability_zone = local.az_names[count.index]
  map_public_ip_on_launch = true
  vpc_id = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]  # Use the CIDR block from the list of public_subnet_cidrs for this subnet creation iteration

  tags = merge(      # Merge all maps into one
    var.common_tags,
    var.public_subnet_cidrs_tags,
    {
      Name = "${local.resource_name}-${local.az_names[count.index]}" # Use the AZ name from the list of az_names for this subnet creation iteration to create a unique name for this subnet resource instance
    }
  )
}
