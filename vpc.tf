resource "aws_vpc" "sect" {
  cidr_block           = local.master_cidr[terraform.workspace]
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(
    local.tags,
    { Name = "sect-vpc" },
    { "kubernetes.io/cluster/sect-${terraform.workspace}" = "shared" }
  )
}

# You really shouldn't use this unless testing something. ALL/ALL is the devil.
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.sect.id
  egress {
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Allow all the things out"
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  }
  ingress {
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Allow all the things in"
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  }
}

resource "aws_subnet" "sect-subnet" {
  for_each          = local.subnet_assignments
  vpc_id            = aws_vpc.sect.id
  cidr_block        = each.value
  availability_zone = join("-", slice(split("-", each.key), 2, 5))

  tags = merge(
    local.tags,
    { Name = each.key },
    (split("-", each.key)[1] != "storage" ? { "kubernetes.io/role/elb" = "1" } : {}),
    (split("-", each.key)[1] == "private" ? { "kubernetes.io/cluster/sect-${terraform.workspace}" = "shared" } : {}),
  )
}

resource "aws_internet_gateway" "sect-internet-gateway" {
  vpc_id = aws_vpc.sect.id

  tags = merge(local.tags, { Name = "sect-vpc" })
}

resource "aws_eip" "sect-public-eip" {
  domain = "vpc"
  tags   = merge(local.tags, { Name = "sect-eip" })
}

resource "aws_nat_gateway" "sect-nat-gateway" {
  depends_on = [aws_internet_gateway.sect-internet-gateway]

  subnet_id         = [for k, v in aws_subnet.sect-subnet : v.id if split("-", k)[1] == "public"][0]
  allocation_id     = aws_eip.sect-public-eip.id
  connectivity_type = "public"
  tags              = merge(local.tags, { Name = "sect-nat-gateway" })
}

resource "aws_route_table" "sect-public-route-table" {
  vpc_id = aws_vpc.sect.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sect-internet-gateway.id
  }

  tags = merge(local.tags, { Name = "sect-public-route-table" })
}

resource "aws_route_table" "sect-private-route-table" {
  vpc_id = aws_vpc.sect.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.sect-nat-gateway.id
  }

  tags = merge(local.tags, { Name = "sect-private-route-table" })
}

resource "aws_route_table" "sect-storage-route-table" {
  vpc_id = aws_vpc.sect.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.sect-nat-gateway.id
  }

  tags = merge(local.tags, { Name = "sect-storage-route-table" })
}

resource "aws_route_table_association" "sect-public-routes" {
  for_each = { for k, v in aws_subnet.sect-subnet : k => v if split("-", k)[1] == "public" }

  subnet_id      = each.value.id
  route_table_id = aws_route_table.sect-public-route-table.id
}

resource "aws_route_table_association" "sect-private-routes" {
  for_each = { for k, v in aws_subnet.sect-subnet : k => v if split("-", k)[1] == "private" }

  subnet_id      = each.value.id
  route_table_id = aws_route_table.sect-private-route-table.id
}

resource "aws_route_table_association" "sect-storage-routes" {
  for_each = { for k, v in aws_subnet.sect-subnet : k => v if split("-", k)[1] == "storage" }

  subnet_id      = each.value.id
  route_table_id = aws_route_table.sect-storage-route-table.id
}