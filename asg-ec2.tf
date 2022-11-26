resource "null_resource" "validate_account" {
  count = var.current_id == var.account_id ? 0 : "Please check that you are using the AWS account"
}

resource "null_resource" "validate_module_name" {
  count = local.module_name == var.tags["TerraformModuleName"] ? 0 : "Please check that you are using the Terraform module"
}

resource "null_resource" "validate_module_version" {
  count = local.module_version == var.tags["TerraformModuleVersion"] ? 0 : "Please check that you are using the Terraform module"
}


resource "aws_autoscaling_group" "this" {

  name = format("%s-%s-autoscaling-group", var.prefix, var.autoscaling-group-name)
  
  launch_template {
    id      = var.launch_template_id
    version = var.launch_template_version
  }

  vpc_zone_identifier         = var.vpc_zone_identifier

  target_group_arns           = var.target_group_arns

  health_check_type           = var.health_check_type
  health_check_grace_period   = var.health_check_grace_period

  max_size                    = var.max_size
  min_size                    = var.min_size
  desired_capacity            = var.desired_capacity
  

  capacity_rebalance          = var.policy_type_num == 0 ? false : true
  default_cooldown            = var.default_cooldown

  protect_from_scale_in       = var.protect_from_scale_in

  termination_policies        = var.termination_policies

  instance_refresh {
    strategy = var.strategy
    preferences {
      min_healthy_percentage  = var.min_healthy_percentage
      instance_warmup         = var.instance_warmup
    }
    #triggers = var.triggers
  }

  dynamic "tag" {
    for_each = var.tags
    iterator = tag
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

# 조정정책  대상 추적 정책만 설정 다른 선택시 모듈 패치 필요
resource "aws_autoscaling_policy" "simple_scaling" {

  count = var.policy_type_num == 1 ? 1 : 0

  name                    = format("%s-%s-autoscaling-group-policy", var.prefix, var.policy_name)
  autoscaling_group_name  = aws_autoscaling_group.this.name

  policy_type             = local.policy_type_list[var.policy_type_num]

  ####################
  # 1. SimpleScaling #
  ####################
  scaling_adjustment  = var.simple_scaling.scaling_adjustment
  adjustment_type     = var.simple_scaling.adjustment_type
  cooldown            = var.simple_scaling.cooldown  
}

resource "aws_autoscaling_policy" "step_scaling" {

  count = var.policy_type_num == 2 ? 1 : 0

  name                    = format("%s-%s-autoscaling-group-policy", var.prefix, var.policy_name)
  autoscaling_group_name  = aws_autoscaling_group.this.name

  policy_type             = local.policy_type_list[var.policy_type_num]

  ##################
  # 2. StepScaling #
  ##################
  metric_aggregation_type = var.step_scaling.metric_aggregation_type
  step_adjustment {
      scaling_adjustment          = var.step_scaling.scaling_adjustment       
      metric_interval_lower_bound = var.step_scaling.metric_interval_lower_bound
      metric_interval_upper_bound = var.step_scaling.metric_interval_upper_bound
    }
}

resource "aws_autoscaling_policy" "target_tracking" {

  count = var.policy_type_num == 3 ? 1 : 0

  name                    = format("%s-%s-autoscaling-group-policy", var.prefix, var.policy_name)
  autoscaling_group_name  = aws_autoscaling_group.this.name

  policy_type             = local.policy_type_list[var.policy_type_num]


  ############################
  # 3. TargetTrackingScaling #
  ############################
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = var.target_tracking.predefined_metric_type
    }
    target_value      = var.target_tracking.target_value
    disable_scale_in  = var.target_tracking.disable_scale_in

  }
}

resource "aws_autoscaling_policy" "predictive" {

  count = var.policy_type_num == 4 ? 1 : 0

  name                    = format("%s-%s-autoscaling-group-policy", var.prefix, var.policy_name)
  autoscaling_group_name  = aws_autoscaling_group.this.name

  policy_type             = local.policy_type_list[var.policy_type_num]


  ########################
  # 4. PredictiveScaling #
  ########################

  predictive_scaling_configuration {
    mode = var.predictive.mode
    metric_specification {
      target_value = var.predictive.target_value
      predefined_load_metric_specification {
        predefined_metric_type = var.predictive.load_predefined_metric_type
        resource_label         = var.predictive.load_resource_label
      }
      predefined_scaling_metric_specification {
        predefined_metric_type  = var.predictive.scaling_predefined_metric_type
        resource_label          = var.predictive.scaling_resource_label
      }
    }
  }
}

# 활동 알림 생성
resource "aws_autoscaling_notification" "this" {
  count = var.notification == true ? 1 : 0

  group_names   = [aws_autoscaling_group.this.name]
  topic_arn     = var.topic_arn
  notifications = var.notifications
}