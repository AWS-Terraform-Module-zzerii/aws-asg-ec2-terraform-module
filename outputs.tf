###################################################################################################
# default outputs
###################################################################################################
output "account_id" {
  description = "AWS Account Id"
  value = var.account_id
}

output "current_id" {
  description = "AWS Account current Id"
  value = var.current_id
}

output "region" {
  description = "AWS region"
  value = var.region
}

output "current_region" {
  description = "Your AWS current region"
  value = var.region
}

output "name" {
  description = "Name of Auto Scaling Group"
  value = var.autoscaling-group-name
}

output "max_size" {
  description = "The maximum size of the Auto Scaling Group."
  value = var.max_size
}

output "min_size" {
  description = "The minimum size of the Auto Scaling Group."
  value = var.min_size
}

output "desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group."
  value = var.desired_capacity
}

output "vpc_zone_identifier" {
  description = "A list of subnet IDs to launch resources in."
  value = var.vpc_zone_identifier
}

output "tags" {
  description = "Your AWS current region"
  value = var.tags
}

###################################################################################################
# about launch template
###################################################################################################
output "launch_template_name" {
  description = "The name of the launch template."
  value = var.launch_template_version
}

output "launch_template_version" {
  description = "Template version. Can be version number, $Latest, or $Default"
  value = var.launch_template_version
}

###################################################################################################
# about autoscaling_policy
###################################################################################################

output "autoscaling_policy_name"{
  value = format("%s-%s-autoscaling-group-policy", var.prefix, var.policy_name)
}

###################################################################################################
# about autoscaling notification
###################################################################################################
output "topic_arn"{
  value = var.topic_arn
}

output "notifications"{
  value = var.notifications
}

output "test" {
  value = var.policy_type_num == 3 ? 1 : 0
}

output "test2" {
  value = aws_autoscaling_policy.predictive[*].name
  
}

output "test3" {
  value = local.policy_type_list[var.policy_type_num]
  
}