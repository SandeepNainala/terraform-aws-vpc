resource "aws_vpc_peering_connection" "peering" {
  count = var.is_peering_required ? 1 : 0
  vpc_id      = aws_vpc.main.id      ## VPC ID of the requester VPC
  peer_vpc_id = aws_vpc.main.id       ## VPC ID of the accepter VPC

}