
#### Project ####
variable "project_name"{
  type = string
}

variable "environment"{
  type = string
  default = "dev"
}

variable "common_tags"{
  type = map
}

#### VPC ####
variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}

variable "enable_dns_hostnames" {
  type = bool
  default = true
}

variable "vpc_tags" {
  type = map
  default = {}
}

#### IGW ####
variable "igw_tags" {
  type = map
  default = {}
}

#### Public Subnet ####
variable "public_subnet_cidrs" {
  type = list
  validation {
    condition = length(var.public_subnet_cidrs) == 2
    error_message = "Please provide exactly 2 public subnet CIDRs"
  }
}

variable "public_subnet_cidrs_tags" {
  type = map
  default = {}
}

#### Private Subnet ####
variable "private_subnet_cidrs" {
  type = list
  validation {
    condition = length(var.private_subnet_cidrs) == 2
    error_message = "Please provide exactly 2 private subnet CIDRs"
  }
}

variable "private_subnet_cidrs_tags" {
  type = map
  default = {}
}
