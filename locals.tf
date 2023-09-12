locals {
  subnet_new_bits = 4
  master_cidr = {
    dev     = "10.10.0.0/16",
    staging = "10.11.0.0/16",
    prod    = "10.12.0.0/16"
  }
  az_ids             = slice(data.aws_availability_zones.all-azs.zone_ids, 0, 3)
  az_names           = slice(data.aws_availability_zones.all-azs.names, 0, 3)
  names              = ["public", "private", "storage"]
  subnet_names       = flatten([for subnet in local.names : [for name in local.az_names : "sect-${subnet}-${name}"]])
  cidr_ranges        = cidrsubnets(local.master_cidr[terraform.workspace], [for i in local.subnet_names : local.subnet_new_bits]...)
  subnet_assignments = zipmap(local.subnet_names, local.cidr_ranges)
  tags = {
    environment = var.environment
    team_name   = "CloudOps"
    managed_by  = "terraform"
  }

  subnets = {
    public  = [for subnet in aws_subnet.sect-subnet : subnet.id if contains(split("-", subnet.tags["Name"]), "public")],
    private = [for subnet in aws_subnet.sect-subnet : subnet.id if contains(split("-", subnet.tags["Name"]), "private")],
    storage = [for subnet in aws_subnet.sect-subnet : subnet.id if contains(split("-", subnet.tags["Name"]), "storage")],
  }

  ecr_repos = toset(["ping", "splunge"])
}