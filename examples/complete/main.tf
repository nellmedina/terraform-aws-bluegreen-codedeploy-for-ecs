provider "aws" {
  region = var.region
}

module "label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.16.0"
  namespace  = var.namespace
  name       = var.name
  stage      = var.stage
  delimiter  = var.delimiter
  attributes = var.attributes
  tags       = var.tags
}

resource "aws_ecs_cluster" "default" {
  name = module.label.id
  tags = module.label.tags
}

module "container_definition" {
  source                       = "git::https://github.com/cloudposse/terraform-aws-ecs-container-definition.git?ref=tags/0.21.0"
  container_name               = var.container_name
  container_image              = data.aws_ecr_repository.this.repository_url
  container_memory             = var.container_memory
  container_memory_reservation = var.container_memory_reservation
  container_cpu                = var.container_cpu
  essential                    = var.container_essential
  readonly_root_filesystem     = var.container_readonly_root_filesystem
  environment                  = var.container_environment
  port_mappings                = var.container_port_mappings
}

module "ecs_alb_service_task" {
  source                             = "git::https://github.com/cloudposse/terraform-aws-ecs-alb-service-task.git?ref=tags/0.21.0"
  namespace                          = var.namespace
  stage                              = var.stage
  name                               = var.name
  attributes                         = var.attributes
  delimiter                          = var.delimiter

  use_alb_security_group             = true
  alb_security_group                 = module.alb.security_group_id

  container_definition_json          = module.container_definition.json
  ecs_cluster_arn                    = aws_ecs_cluster.default.arn
  launch_type                        = var.ecs_launch_type

  vpc_id                             = var.vpc_id
  # security_group_ids                 = ["sg-08b8996dafbef4506"]
  subnet_ids                         = var.subnet_ids

  tags                               = var.tags
  ignore_changes_task_definition     = var.ignore_changes_task_definition
  network_mode                       = var.network_mode
  assign_public_ip                   = var.assign_public_ip
  propagate_tags                     = var.propagate_tags
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_controller_type         = var.deployment_controller_type
  desired_count                      = var.desired_count
  task_memory                        = var.task_memory
  task_cpu                           = var.task_cpu

  ecs_load_balancers                 = local.load_balancers
  container_port                     = var.container_port
}

data "aws_ssm_parameter" "github_token" {
  name = var.github_oauth_token
}

data "aws_ecr_repository" "this" {
  name = var.container_name
}

data "aws_caller_identity" "current" {}

resource "aws_lb_target_group" "green" {
  name        = "green"
  vpc_id      = var.vpc_id
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"
}

locals {
  alb = {
    container_name   = var.container_name
    container_port   = var.container_port
    elb_name         = null
    target_group_arn = module.alb_ingress.target_group_arn
  }
  load_balancers = [local.alb]

  github_token = data.aws_ssm_parameter.github_token.value

  blue_lb_target_group_name  = module.alb_ingress.target_group_name
  green_lb_target_group_name = aws_lb_target_group.green.name

  environment_variables = [
    {
        name  = "REPOSITORY_URI"
        value = data.aws_ecr_repository.this.repository_url
    },
    {
        name  = "CONTAINER_NAME"
        value = var.container_name
    },
    {
        name  = "CONTAINER_PORT"
        value = var.container_port
    },
    {
        name  = "TASK_DEFINITION"
        value = "arn:aws:ecs:${var.region}:${data.aws_caller_identity.current.account_id}:task-definition/${module.ecs_alb_service_task.task_definition_family}"
    },
    {
        name  = "TASK_DEFINITION_FAMILY"
        value = module.ecs_alb_service_task.task_definition_family
    },
    {
        name  = "SUBNET_1"
        value = var.subnet_ids[0]
    },
    {
        name  = "SUBNET_2"
        value = var.subnet_ids[1]
    },
    {
        name  = "SECURITY_GROUP"
        value = module.ecs_alb_service_task.service_security_group_id
    }
  ]
}

module "ecs_codepipeline" {
  source                  = "../../"
  namespace               = var.namespace
  stage                   = var.stage
  name                    = var.name
  region                  = var.region
  github_oauth_token      = local.github_token
  github_webhooks_token   = local.github_token
  repo_owner              = var.repo_owner
  repo_name               = var.repo_name
  branch                  = var.branch
  build_image             = var.build_image
  build_compute_type      = var.build_compute_type
  build_timeout           = var.build_timeout
  poll_source_changes     = var.poll_source_changes
  privileged_mode         = var.privileged_mode
  image_repo_name         = var.image_repo_name
  image_tag               = var.image_tag
  webhook_enabled         = var.webhook_enabled
  s3_bucket_force_destroy = var.s3_bucket_force_destroy
  environment_variables   = local.environment_variables
  ecs_cluster_name        = aws_ecs_cluster.default.name
  service_name            = module.ecs_alb_service_task.service_name

  blue_lb_target_group_name  = local.blue_lb_target_group_name
  green_lb_target_group_name = local.green_lb_target_group_name
  lb_listener_arns           = module.alb.listener_arns
}

module "alb" {
  source                                  = "git::https://github.com/cloudposse/terraform-aws-alb.git?ref=tags/0.7.0"
  namespace                               = var.namespace
  stage                                   = var.stage
  name                                    = var.name
  attributes                              = var.attributes
  delimiter                               = var.delimiter

  vpc_id                                  = var.vpc_id
  # security_group_ids                      = ["sg-08b8996dafbef4506"]
  subnet_ids                              = var.subnet_ids

  internal                                = var.internal
  http_enabled                            = var.http_enabled
  access_logs_enabled                     = var.access_logs_enabled
  alb_access_logs_s3_bucket_force_destroy = var.alb_access_logs_s3_bucket_force_destroy
  access_logs_region                      = var.access_logs_region
  cross_zone_load_balancing_enabled       = var.cross_zone_load_balancing_enabled
  http2_enabled                           = var.http2_enabled
  idle_timeout                            = var.idle_timeout
  ip_address_type                         = var.ip_address_type
  deletion_protection_enabled             = var.deletion_protection_enabled
  deregistration_delay                    = var.deregistration_delay
  health_check_path                       = var.health_check_path
  health_check_timeout                    = var.health_check_timeout
  health_check_healthy_threshold          = var.health_check_healthy_threshold
  health_check_unhealthy_threshold        = var.health_check_unhealthy_threshold
  health_check_interval                   = var.health_check_interval
  health_check_matcher                    = var.health_check_matcher
  target_group_port                       = var.target_group_port
  target_group_target_type                = var.target_group_target_type
  tags                                    = var.tags
}

module "alb_ingress" {
  source                              = "git::https://github.com/cloudposse/terraform-aws-alb-ingress.git?ref=tags/0.9.0"
  namespace                           = var.namespace
  stage                               = var.stage
  name                                = var.name
  attributes                          = var.attributes
  delimiter                           = var.delimiter

  vpc_id                              = var.vpc_id
  authentication_type                 = var.authentication_type
  unauthenticated_priority            = var.unauthenticated_priority
  unauthenticated_paths               = var.unauthenticated_paths
  slow_start                          = var.slow_start
  stickiness_enabled                  = var.stickiness_enabled
  default_target_group_enabled        = false
  target_group_arn                    = module.alb.default_target_group_arn
  unauthenticated_listener_arns       = [module.alb.http_listener_arn]
  unauthenticated_listener_arns_count = 1
  tags                                = var.tags
}
