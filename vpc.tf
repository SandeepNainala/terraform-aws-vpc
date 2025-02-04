
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
    count = length(var.public_subnet_cidrs)  # Create one IGW per public subnet CIDR block in the list of public_subnet_cidrs
    vpc_id = aws_vpc.main.id      # Attach the IGW to the VPC
    cidr_block = var.public_subnet_cidrs[count.index]    # Use the current public subnet CIDR block from the list of public_subnet_cidrs as the IGW CIDR block (this is a dummy value)

    tags = merge(           # Merge all maps into one
        var.common_tags,
        var.igw_tags,
        {
        Name = local.resource_name
        }
    )
}
