## What you need to do to run this file
# 1. Install Terraform and modify variables in aws.tfvars
# 2. Run these commands:
#   terraform init
#   terraform plan -var-file="aws.tfvars"
#   terraform apply -var-file="aws.tfvars" -auto-approve
# 3. Validate that the IPsec tunnels are up and running
# 4. To remove the config from AWS, run the following command
#    terraform destroy -var-file="aws.tfvars" -auto-approve

# 1a. Create a Virtual Private Gateway (VPG)
#   b. Attach VPG to VPC
#   c. Enable RoutePropogation on VPG
# 2a. VPN Connection
#   b. Create Customer Gateway (select “New”)
#   c. Attach VPN to the Customer Gateway by creating a VPN Connection (Tunnel 1 & 2 outside IPs generated at this step)

provider "aws" {
  shared_config_files      = [".aws/config"]
  shared_credentials_files = [".aws/credentials"]
}


# 1a. Create a Virtual Private Gateway (VPGW)
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_gateway
resource "aws_vpn_gateway" "vpn_gw" {
  vpc_id = var.aws_vpc

  tags = {
    Name = "August 2023 Virtual Private Gateway created by Terraform"
  }
}

# 1b: Attach VPN/VPGW to VPC
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_gateway_attachment
resource "aws_vpn_gateway_attachment" "vpn_attachment" {
  vpc_id         = var.aws_vpc
  vpn_gateway_id = aws_vpn_gateway.vpn_gw.id
}

# 1c: Enable Route Propogation
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_gateway_route_propagationdata "aws_route_tables" "rts" {
resource "aws_vpn_gateway_route_propagation" "example" {
  vpn_gateway_id = aws_vpn_gateway.vpn_gw.id
  route_table_id = var.aws_route
}

# 2a: Create Customer Gateway
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/customer_gateway
resource "aws_customer_gateway" "main" {
  bgp_asn    = 65000
  ip_address = var.customer_gw
  type       = "ipsec.1"

  tags = {
    Name = "August 2023 Customer Gateway created by Terraform"
  }
}

# 2b: Create a VPN connection between the VPN and Customer Gateway (created in the two previous steps)
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_connection
resource "aws_vpn_connection" "main" {
  vpn_gateway_id      = aws_vpn_gateway.vpn_gw.id
  customer_gateway_id = aws_customer_gateway.main.id
  type                = "ipsec.1"
  static_routes_only  = true
  tunnel1_inside_cidr   = var.tunnel1_inside_cidr
  tunnel2_inside_cidr   = var.tunnel2_inside_cidr
  tunnel1_preshared_key = var.psk
  tunnel2_preshared_key = var.psk2
  
  
  tags = {
    Name = "August 2023 VPN Connection created by Terraform"
  }
}

# 2c: CIDR block for VPN Connection
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_connection_route
resource "aws_vpn_connection_route" "main" {
  destination_cidr_block = var.destination_cidr_block
  vpn_connection_id      = aws_vpn_connection.main.id
}
