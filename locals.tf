locals {
  resource_name = "${var.project_name}-${var.environment}"
  az_names = slice(data.aws_availability_zones.available.names, 0, 2) # slice is a function, Get the first two AZs in the region for the cluster to span across them
}
