locals{
  policy_type_list = [null, "SimpleScaling","StepScaling", "TargetTrackingScaling", "PredictiveScaling"]
}

locals {
  module_name    = "terraform-aws-module-asg-ec2"
  module_version = "v1.0.2"
}
