resource "aws_vpc_peering_connection" "peering" {
  count = var.is_peering_required ? 1 : 0   # if user provides peering its 1 or false is default, nothing runs
  vpc_id        = aws_vpc.main.id # requestor VPC
  peer_vpc_id   = var.acceptor_vpc_id == "" ? data.aws_vpc.default.id : var.acceptor_vpc_id
  auto_accept = var.acceptor_vpc_id == "" ? true : false   # it can work if in the same account
  tags = merge(    # tags are for names
    var.common_tags,
    var.vpc_peering_tags,
    {
        Name = "${local.resource_name}" #expense-dev
    }
  )
}

# count is useful to control when resource is required
resource "aws_route" "public_peering" {
  count = var.is_peering_required && var.acceptor_vpc_id == "" ? 1 : 0  # when acceptor vpc is default. 2 conditions
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id  #as we gave count its list so, we give peering of 0 are [count.index] as it is zero
}

resource "aws_route" "private_peering" {
  count = var.is_peering_required && var.acceptor_vpc_id == "" ? 1 : 0
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
}

resource "aws_route" "database_peering" {
  count = var.is_peering_required && var.acceptor_vpc_id == "" ? 1 : 0
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
}

resource "aws_route" "default_peering" {  # for defulat vpc for perring to expense vpc
  count = var.is_peering_required && var.acceptor_vpc_id == "" ? 1 : 0
  route_table_id            = data.aws_route_table.main.id # default vpc route table $ # from data source fetching
  destination_cidr_block    = var.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
}




