output "tunnel1" {
    value = aws_vpn_connection.main.tunnel1_address
    sensitive = false
}

output "tunnel2" {
    value = aws_vpn_connection.main.tunnel2_address
    sensitive = false
}
