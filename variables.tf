###################################################################################################
# default variables
###################################################################################################
variable "account_id" {
  description = "AWS account ID"
  type = string
}

variable "current_id" {
  description = "Your current AWS account ID"
  type = string
}

variable "region" {
  description = "AWS Region"
  type = string
}

variable "current_region" {
  description = "Your currnet AWS region"
  type = string
}

variable "prefix" {
  description = "prefix for aws resources and tags"
  type = string
}

variable "autoscaling-group-name" {
  description = "Name of Auto Scaling Group"
  type = string
}

variable "vpc_zone_identifier" {
  description = "A list of subnet IDs to launch resources in."
  type = list(string)  
}

variable "target_group_arns" {
  type = list(string)
}

variable "max_size" {
  description = "The maximum size of the Auto Scaling Group."
  type = number
}

variable "min_size" {
  description = "The minimum size of the Auto Scaling Group."
  type = number
}

variable "desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group."
  type = number
}


variable "default_cooldown" {
  description = "Time between a scaling activity and the succeeding scaling activity."
  type = number
}

variable "protect_from_scale_in" {
  description = "Allows setting instance protection. "
  type = bool
}

variable "termination_policies" {
  description = "A list of policies to decide how the instances in the Auto Scaling Group should be terminated"
  type = list(string)
}

variable "tags" {
  description = "The map of tags"
  type = map(string)
}

###################################################################################################
# about launch template
###################################################################################################
variable "launch_template_id" {
  description = "The name of the launch template."
  type = string
}

variable "launch_template_version" {
  description = "Template version. Can be version number, $Latest, or $Default"
  type = string
}

###################################################################################################
# health check
###################################################################################################
variable "health_check_type" {
  description = "health_check_type EC2 or ELB"
  type = string
}

variable "health_check_grace_period" {
  description = "health_check_grace_period"
  type = number
}

###################################################################################################
# about instance refresh
###################################################################################################
variable "strategy" {
  description = "The strategy to use for instance refresh."
  type = string
}

variable "min_healthy_percentage" {
  description = "The amount of capacity in the Auto Scaling group that must remain healthy during an instance refresh to allow the operation to continue, as a percentage of the desired capacity of the Auto Scaling group. Defaults to 90."
  type = number
}

variable "instance_warmup" {
  description = "The number of seconds until a newly launched instance is configured and ready to use"
  type = number
}

#variable "triggers" {
#  description = "Set of additional property names that will trigger an Instance Refresh."
#  type = list(string)
#}

###################################################################################################
# aws_autoscaling_policy
###################################################################################################
variable "policy_name" {
  description = "The name of the policy."
  type = string
}

variable "policy_type_num" {
  description = "The type of the policy."
  type = number
}

variable "simple_scaling" {
    type = map(any)
}

variable "step_scaling" {
    type = map(any)
}

variable "target_tracking" {
    type = map(any)
}

variable "predictive" {
    type = map(any)
}
###################################################################################################
# SNS NOTIFICATIONS
###################################################################################################
variable "notification" {
  type = bool
}

variable "topic_arn" {
  type = string
  default = ""
}

variable "notifications" {
  type = list(string)
  default = []
}