output "eice_ssh_id" {
  value       = aws_security_group.eice_ssh.id
  description = "The ID of the Internet Gateway"
}
