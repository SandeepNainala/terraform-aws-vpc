resource "aws_vpc_peering_connection" "peering" {
  count = var.is_peering_required ? 1 : 0
  vpc_id      = aws_vpc.main.id      ## VPC ID of the requester VPC
  peer_vpc_id = var.acceptor_vpc_id == "" ? data.aws_vpc.default.id : var.acceptor_vpc_id   ## VPC ID of the accepter VPC (default VPC)
  auto_accept = var.acceptor_vpc_id == "" ? true : false
}


# count is useful  to control the number of resources to be created or required based on the condition
# if the condition is true then it will create the resource otherwise it will not create the resource
# if the condition is false then it will not create the resource

resource "aws_route" "public_peering" {
  count = var.is_peering_required ? 1 : 0
  route_table_id = aws_route_table.public.id
  destination_cidr_block = data.aws_vpc.default.cidr_block   ## CIDR block of the acceptor VPC (default VPC)
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id  # VPC peering connection ID
}

resource "aws_route" "private_peering" {
  count = var.is_peering_required ? 1 : 0
  route_table_id = aws_route_table.private.id
  destination_cidr_block = data.aws_vpc.default.cidr_block   ## CIDR block of the acceptor VPC (default VPC)
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id  # VPC peering connection ID
}

resource "aws_route" "database_peering" {
  count = var.is_peering_required ? 1 : 0
  route_table_id = aws_route_table.database.id
  destination_cidr_block = data.aws_vpc.default.cidr_block   ## CIDR block of the acceptor VPC (default VPC)
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id  # VPC peering connection ID
}

