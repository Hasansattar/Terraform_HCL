output "IPaddress_instance" {
  value       = aws_instance.firstServer.public_ip
}

output "DNS_instance" {
  value       = aws_instance.firstServer.dns
}
