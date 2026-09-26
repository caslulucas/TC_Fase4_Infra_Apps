# =====================================================================
# VPC PRINCIPAL
# Rede base que hospedará EKS, bancos de dados e demais serviços.
# =====================================================================


resource "aws_vpc" "this" {
  # Bloco CIDR da rede principal
  cidr_block = var.vpc_cidr
  # Habilita resolucao DNS interna da AWS
  enable_dns_support = true
  # Habilita hostname DNS para recursos para EKS e servicos internos
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-${var.environment}-vpc"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id = aws_vpc.this.id

  cidr_block = "10.0.1.0/24"

  availability_zone = var.availability_zones[0]

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-${var.environment}-public-a"

    #tag para que o ELB seja criado nas subnets publicas
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id = aws_vpc.this.id

  cidr_block = "10.0.2.0/24"

  availability_zone = var.availability_zones[1]

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-${var.environment}-public-b"

    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id = aws_vpc.this.id

  cidr_block = "10.0.11.0/24"

  availability_zone = var.availability_zones[0]

  tags = {
    Name = "${var.project_name}-${var.environment}-private-a"

    #tag para que o ELB seja criado nas subnets privadas
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id = aws_vpc.this.id

  cidr_block = "10.0.12.0/24"

  availability_zone = var.availability_zones[1]

  tags = {
    Name = "${var.project_name}-${var.environment}-private-b"

    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project_name}-${var.environment}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-public-rt"
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

# Endereço IP público estático utilizado pelo NAT Gateway
resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? 1 : 0
  domain = "vpc"
  tags = {
    Name = "${var.project_name}-${var.environment}-nat-eip"
  }
}

# Permite que recursos em subnets privadas acessem a internet
resource "aws_nat_gateway" "this" {
  count         = var.enable_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public_a.id
  tags = {
    Name = "${var.project_name}-${var.environment}-nat"
  }
  depends_on = [
    aws_internet_gateway.this
  ]
}

# Tabela de rotas utilizada pelas subnets privadas
resource "aws_route_table" "private" {
  count  = var.enable_nat_gateway ? 1 : 0
  vpc_id = aws_vpc.this.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[0].id
  }
  tags = {
    Name = "${var.project_name}-${var.environment}-private-rt"
  }
}

#Associa a tabela de rotas privadas com as subnets privadas
resource "aws_route_table_association" "private_a" {
  count          = var.enable_nat_gateway ? 1 : 0
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private[0].id
}

resource "aws_route_table_association" "private_b" {
  count          = var.enable_nat_gateway ? 1 : 0
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private[0].id
}