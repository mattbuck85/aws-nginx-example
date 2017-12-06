provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "us-east-1"
}
resource "aws_vpc" "default" {
  cidr_block = "${var.vpc_cidr_block}"
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

resource "aws_subnet" "default" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${var.subnet_cidr_block}"
  map_public_ip_on_launch = true
}
/*
resource "aws_vpn_gateway" "vpn_gw" {
  vpc_id = "${aws_vpc.default.id}"
}

resource "aws_customer_gateway" "customer_gw" {
  bgp_asn     = 65000
  ip_address  = "18.217.71.53"
  type        = "ipsec.1"
}
resource "aws_vpn_connection" "main" {
  vpn_gateway_id      = "${aws_vpn_gateway.vpn_gw.id}"
  customer_gateway_id = "${aws_customer_gateway.customer_gw.id}"
  type		      = "ipsec.1"
}
*/
