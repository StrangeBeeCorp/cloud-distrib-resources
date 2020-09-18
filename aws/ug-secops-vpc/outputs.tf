output "bastion-host_public_ip" {
  value = aws_eip.bastion-host-secops-eip.public_ip
}