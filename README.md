# terraform-aws-module-asg-ec2

AWS auto scaling group(asg) 를 생성하는 공통 모듈

### version
v1.0.1  => LB 미부착 version
v1.0.2  => LB 부착 version

## Usage

### `terraform.tfvars`

- 모든 변수는 적절하게 변경하여 사용

```plaintext
account_id                  = "1232412314" # 아이디 변경 필수
region                      = "ap-northeast-2"
prefix                      = "dev"

#"{prefix}-{name}-autoscaling-group"
autoscaling-group-name      = "test"

#launch_template 설정
launch_template_name        = "eks-test-eks-node-launch-template"
launch_template_version     = "$Latest"      # $Default/ $Latest / 템플릿 버전.버전 번호


vpc_filters = {
  "Name" = "eks-test-vpc"
}

subnet_filters = {
  "Name" = ["eks-test-vpc-subnet-private1-2a","eks-test-vpc-subnet-private2-2c"]
}


# 로드벨런서 적용 
# 타겟그룹 생성ver
target_group_arns            = ""

# health check
health_check_type           = "ELB"  # EC2  or ELB  (ELB를 입력해도 EC2는 자동 선택되어 있습니다.)
health_check_grace_period   = 300    # health check 유예 기간 

# 용량
max_size                    = 4
min_size                    = 2
desired_capacity            = 2

# 조정 정책
default_cooldown            = 300   #지표에 포함하기 전 워밍업 시간(초)

protect_from_scale_in       = false    # 인스턴스 축소 보호

# 종료 정책
# OldestInstance, NewestInstance, OldestLaunchConfiguration,
# ClosestToNextInstanceHour, OldestLaunchTemplate,
# AllocationStrategy, Default
termination_policies        = ["Default"]

# 인스턴스 새로고침
strategy                    = "Rolling"  # Default == Rolling // 새로고침 전략
min_healthy_percentage      = 50  #최소 정상 백분율 default == 90
instance_warmup             = 300 # 새로 시작된 인스턴스를 사용할 준비가 되는 데 걸리는 시간
# triggers = ["tag"]  # 나중에 다시 설정


###################################################################################################
# aws_autoscaling_policy
###################################################################################################

#{prefix}-{name}-autoscaling-group-policy
policy_name                 = "test"     

# 조정정책 비활 = 0 / SimpleScaling = 1 / StepScaling = 2 / TargetTrackingScaling = 3 / PredictiveScaling = 4

policy_type_num             = 4

# # ChangeInCapacity / ExactCapacity / PercentChangeInCapacity

####################
# 1. SimpleScaling #
####################
# 조정 범위를 위반한 경우 확장할 인스턴스 수
simple_scaling = {
    scaling_adjustment     = 4
    adjustment_type        = "ChangeInCapacity"
    cooldown               = 300
}
##################
# 2. StepScaling #
##################
step_scaling = {
    # Minimum / Maximum / Average
    metric_aggregation_type         = "Average"

    scaling_adjustment              = -1
    metric_interval_lower_bound     = 1.0
    metric_interval_upper_bound     = 2.0 
}

############################    
# 3. TargetTrackingScaling #
############################
target_tracking = {
    # 지표 유형
    predefined_metric_type      = "ASGAverageCPUUtilization"
    # ASGAverageCPUUtilization / ASGAverageNetworkIn /
    # ASGAverageNetworkOut / ALBRequestCountPerTarget

    target_value                = 40.0  # 대상 값
    disable_scale_in            = false
}
########################
# 4. PredictiveScaling #
########################
predictive ={

    #ForecastAndScale  / ForecastOnly
    mode                        = "ForecastOnly"

    target_value                = 10

    #############
    # load_metric
    #############
    #ASGTotalCPUUtilization / ASGTotalNetworkIn / ASGTotalNetworkOut / ALBTargetGroupRequestCount
    load_predefined_metric_type      = "ASGTotalCPUUtilization"
    load_resource_label              = "testLabel"

    ################
    # scaling_metric
    ################
    # ASGAverageCPUUtilization / ASGAverageNetworkIn / ASGAverageNetworkOut / ALBRequestCountPerTarget
    scaling_predefined_metric_type      = "ASGAverageCPUUtilization"
    scaling_resource_label              = "testLabel"

}
###

###
# sns 알림 설정
notification                = true
topic_name                  = "test_topic"


 # 해당되는 알림 설정만 입력해주세요
  # [
  #   "autoscaling:EC2_INSTANCE_LAUNCH",
  #   "autoscaling:EC2_INSTANCE_TERMINATE",
  #   "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
  #   "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  # ]
notifications               = [
    # "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]
 

tags = {
    "CreatedByTerraform"     = "true"
    "TerraformModuleName"    = "terraform-aws-module-asg-ec2"
    "TerraformModuleVersion" = "v1.0.2"
}



```

------

### `main.tf`

```plaintext
module "autoscaling-group" {
    source = "git::https://github.com/aws-asg-ec2-terraform-module?ref=v1.0.2"

    current_id     = data.aws_caller_identity.current.account_id
    current_region = data.aws_region.current.name


    account_id                  = var.account_id
    region                      = var.region
    prefix                      = var.prefix

    autoscaling-group-name      = var.autoscaling-group-name

    launch_template_id          = data.aws_launch_template.this.id
    launch_template_version     = var.launch_template_version

    vpc_zone_identifier         = data.aws_subnet_ids.this.ids

    target_group_arns           = var.target_group_arns

    health_check_type           = var.health_check_type
    health_check_grace_period   = var.health_check_grace_period

    max_size                    = var.max_size
    min_size                    = var.min_size
    desired_capacity            = var.desired_capacity

    default_cooldown            = var.default_cooldown

    protect_from_scale_in       = var.protect_from_scale_in

    termination_policies        = var.termination_policies

    strategy                    = var.strategy
    min_healthy_percentage      = var.min_healthy_percentage
    instance_warmup             = var.instance_warmup

    policy_name                 = var.policy_name
    policy_type_num             = var.policy_type_num

    simple_scaling              = var.simple_scaling
    step_scaling                = var.step_scaling
    target_tracking             = var.target_tracking
    predictive                  = var.predictive

    notification                = var.notification
    topic_arn                   = data.aws_sns_topic.this.arn
    notifications               = var.notifications

    tags                        = var.tags

    
}
```

------

### `provider.tf`

```plaintext
provider "aws" {
   region = var.region
}
```

------

### `terraform.tf`

```plaintext
terraform {
  required_version = ">= 1.1.2"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "= 3.74"
    }
  }


  backend "s3" {
    bucket         = "kcl-dev-tf-state-backend"
    key            = "012345678912/dev/common/asg/terraform.state"
    region         = "ap-northeast-2"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}
```

------

### `data.tf`

```plaintext
data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_vpc" "this" {
  dynamic "filter" {
    for_each = var.vpc_filters
    iterator = tag
    content {
      name   = "tag:${tag.key}"
      values = [tag.value]
    }
  }
}

data "aws_subnet_ids" "this" {
  vpc_id = data.aws_vpc.this.id
  dynamic "filter" {
    for_each = var.subnet_filters
    iterator = tag
    content {
      name   = "tag:${tag.key}"
      values = "${tag.value}"
    }
  }
}


data "aws_launch_template" "this" {
    filter {
        name   = "launch-template-name"
        values = ["${var.launch_template_name}"]
  }
}

data "aws_sns_topic" "this" {
  name   = var.topic_name
}
```

------

### `variables.tf`

```plaintext
###################################################################################################
# default variables
###################################################################################################
variable "account_id" {
  description = "AWS account ID"
  type = string
  default = ""
}

variable "current_id" {
  description = "Your current AWS account ID"
  type = string
  default = ""
}

variable "region" {
  description = "AWS Region"
  type = string
  default = ""
}

variable "current_region" {
  description = "Your currnet AWS region"
  type = string
  default = ""
}

variable "prefix" {
  description = "prefix for aws resources and tags"
  type = string
  default = ""
}

variable "autoscaling-group-name" {
  description = "Name of Auto Scaling Group"
  type = string
  default = ""
}

variable "vpc_filters" {
  description = "Filters to select subnets"
  type        = map(string)
  default = {}
}

variable "subnet_filters" {
  description = "Filters to select subnets"
  type        = map(list(string))
  default = {}
}

variable "target_group_arns" {
    type = string
    default = null
}

variable "max_size" {
  description = "The maximum size of the Auto Scaling Group."
  type = number
  default = null
}

variable "min_size" {
  description = "The minimum size of the Auto Scaling Group."
  type = number
  default = null
}

variable "desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group."
  type = number
  default = null
}

variable "default_cooldown" {
  description = "Time between a scaling activity and the succeeding scaling activity."
  type = number
  default = null
}

variable "protect_from_scale_in" {
  description = "Allows setting instance protection. "
  type = bool
  default = null
}

variable "termination_policies" {
  description = "A list of policies to decide how the instances in the Auto Scaling Group should be terminated"
  type = list(string)
  default = []
}

variable "tags" {
  description = "The map of tags"
  type = map(string)
  default = {}
}

###################################################################################################
# about launch template
###################################################################################################
variable "launch_template_name" {
  description = "The name of the launch template."
  type = string
  default = ""
}

variable "launch_template_version" {
  description = "Template version. Can be version number, $Latest, or $Default"
  type = string
  default = ""
}


###################################################################################################
# health check
###################################################################################################
variable "health_check_type" {
  description = "health_check_type EC2 or ELB"
  type = string
  default = ""
}

variable "health_check_grace_period" {
  description = "health_check_grace_period"
  type = number
  default = null
}

###################################################################################################
# about instance refresh
###################################################################################################
variable "strategy" {
  description = "The strategy to use for instance refresh."
  type = string
  default = ""
}

variable "min_healthy_percentage" {
  description = "The amount of capacity in the Auto Scaling group that must remain healthy during an instance refresh to allow the operation to continue, as a percentage of the desired capacity of the Auto Scaling group. Defaults to 90."
  type = number
  default = null
}

variable "instance_warmup" {
  description = "The number of seconds until a newly launched instance is configured and ready to use"
  type = number
  default = null
}

#variable "triggers" {
#  description = "Set of additional property names that will trigger an Instance Refresh."
#  type = list(string)
#  default = []
# }

###################################################################################################
# aws_autoscaling_policy
###################################################################################################
variable "policy_name" {
  description = "The name of the policy."
  type = string
  default = ""
}

variable "policy_type_num" {
  description = "The type of the policy."
  type = number
}

variable "simple_scaling" {
    type = map(any)
    default = {}
}

variable "step_scaling" {
    type = map(any)
    default = {}
}

variable "target_tracking" {
    type = map(any)
    default = {}
}

variable "predictive" {
    type = map(any)
    default = {}
}
###################################################################################################
# SNS NOTIFICATIONS
###################################################################################################
variable "notification" {
  type = bool
}

variable "topic_name" {
  type = string
}

variable "notifications" {
  type = list(string)
}
```

------

### `outputs.tf`

```plaintext
output "result" {
    value = module.autoscaling-group
}

```

## 실행방법

```plaintext
terraform init -get=true -upgrade -reconfigure
terraform validate (option)
terraform plan -var-file=terraform.tfvars -refresh=false -out=planfile
terraform apply planfile
```

- "Objects have changed outside of Terraform" 때문에 `-refresh=false`를 사용
- 실제 UI에서 리소스 변경이 없어보이는 것과 low-level Terraform에서 Object 변경을 감지하는 것에 차이가 있는 것 같음, 다음 링크 참고
  - https://github.com/hashicorp/terraform/issues/28776
- 위 이슈로 변경을 감지하고 리소스를 삭제하는 케이스가 발생 할 수 있음