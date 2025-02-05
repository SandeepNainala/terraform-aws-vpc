resource "aws_vpc_peering_connection" "peering" {
  count = var.is_peering_required ? 1 : 0
  vpc_id      = aws_vpc.main.id      ## VPC ID of the requester VPC
  peer_vpc_id = var.acceptor_vpc_id == "" ? data.aws_vpc.default.id : var.acceptor_vpc_id   ## VPC ID of the accepter VPC (default VPC)
}