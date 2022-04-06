output "thehive_private_ip" {
  value = var.secops_thehive_init ? aws_instance.secops-instance-thehive[0].private_ip : aws_instance.secops-instance-thehive-restore[0].private_ip
  description = "Private IP of TheHive instance"
}

output "thehive_instance_arn" {
  value = var.secops_thehive_init ? aws_instance.secops-instance-thehive[0].arn : aws_instance.secops-instance-thehive-restore[0].arn
  description = "ARN of TheHive instance"
}

output "thehive_instance_id" {
  value = var.secops_thehive_init ? aws_instance.secops-instance-thehive[0].id : aws_instance.secops-instance-thehive-restore[0].id
  description = "ID of TheHive instance"
}

output "cortex_private_ip" {
  value = var.secops_cortex_init ? aws_instance.secops-instance-cortex[0].private_ip : aws_instance.secops-instance-cortex-restore[0].private_ip
  description = "Private IP of Cortex instance"
}

output "cortex_instance_arn" {
  value = var.secops_cortex_init ? aws_instance.secops-instance-cortex[0].arn : aws_instance.secops-instance-cortex-restore[0].arn
  description = "ARN of Cortex instance"
}

output "cortex_instance_id" {
  value = var.secops_cortex_init ? aws_instance.secops-instance-cortex[0].id : aws_instance.secops-instance-cortex-restore[0].id
  description = "ID of Cortex instance"
}
