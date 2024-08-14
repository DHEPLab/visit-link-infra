data "aws_availability_zones" "available_zones" {
}

resource "aws_vpc" "vpc" {
  cidr_block           = local.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc-${var.env}"
  }
}

resource "aws_subnet" "private_subnets" {
  count             = var.az_count
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]
  vpc_id            = aws_vpc.vpc.id

  tags = {
    "Name" = "${var.project_name}-private-subnet-${count.index + 1}-${var.env}"
  }
}

resource "aws_subnet" "public_subnets" {
  count                   = var.az_count
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 8, var.az_count + count.index)
  availability_zone       = data.aws_availability_zones.available_zones.names[count.index]
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = var.env == "prod" ? false : true

  tags = {
    "Name" = "${var.project_name}-public-subnet-${count.index + 1}-${var.env}"
  }
}

# Route the public subnet traffic through the IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-igw-${var.env}"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-public-rt-${var.env}"
  }
}

resource "aws_route_table_association" "public_subnet_associate" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.public_rt.id
}

# Create a NAT gateway with an Elastic IP for each private subnet to get internet connectivity
resource "aws_eip" "eip" {
  domain = "vpc"
  count  = var.az_count

  tags = {
    Name = "${var.project_name}-eip-${var.env}"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat" {
  count         = var.az_count
  subnet_id     = element(aws_subnet.public_subnets[*].id, count.index)
  allocation_id = element(aws_eip.eip[*].id, count.index)

  tags = {
    Name = "${var.project_name}-nat-gw-${var.env}"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "private_rt" {
  count  = var.az_count
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.nat[*].id, count.index)
  }

  tags = {
    Name = "${var.project_name}-private-rt-${var.env}"
  }
}


resource "aws_route_table_association" "private_subnet_associate" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
  route_table_id = element(aws_route_table.private_rt[*].id, count.index)
}

