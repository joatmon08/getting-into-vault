resource "hcp_hvn" "hvn" {
  hvn_id         = "${var.name}-live"
  cloud_provider = "aws"
  region         = var.region
  cidr_block     = var.hvn_cidr_block
}

resource "hcp_aws_network_peering" "peer" {
  hvn_id          = hcp_hvn.hvn.hvn_id
  peer_vpc_id     = local.vpc.vpc_id
  peer_account_id = local.vpc.vpc_owner_id
  peer_vpc_region = var.region
  peering_id      = hcp_hvn.hvn.hvn_id
}

resource "aws_vpc_peering_connection_accepter" "hvn" {
  vpc_peering_connection_id = hcp_aws_network_peering.peer.provider_peering_id
  auto_accept               = true
}

resource "aws_route" "hvn" {
  count                     = length(local.vpc.private_route_table_ids)
  route_table_id            = local.vpc.private_route_table_ids[count.index]
  destination_cidr_block    = var.hvn_cidr_block
  vpc_peering_connection_id = hcp_aws_network_peering.peer.provider_peering_id
}

resource "hcp_hvn_route" "hvn" {
  hvn_link         = hcp_hvn.hvn.self_link
  hvn_route_id     = "${hcp_hvn.hvn.hvn_id}-to-vpc"
  destination_cidr = local.vpc.vpc_cidr_block
  target_link      = hcp_aws_network_peering.peer.self_link
}