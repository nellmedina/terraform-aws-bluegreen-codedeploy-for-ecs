region = "ap-southeast-1"
availability_zones = ["ap-southeast-1a", "ap-southeast-1b"]

namespace = "nm"
stage = "dev"
name = "ecs1"
attributes  = ["part3"]

vpc_cidr_block = "172.16.0.0/16"

ecs_launch_type = "FARGATE"
network_mode = "awsvpc"
ignore_changes_task_definition = true
assign_public_ip = true

propagate_tags = "TASK_DEFINITION"

deployment_minimum_healthy_percent = 100

deployment_maximum_percent = 200

deployment_controller_type = "ECS"

desired_count = 1

task_memory = 1024

task_cpu = 512

container_name = "springboot-service-1"
container_image = "641278899178.dkr.ecr.ap-southeast-1.amazonaws.com/springboot-service-1"
container_memory = 1024
container_memory_reservation = 128
container_cpu = 512
container_essential = true
container_readonly_root_filesystem = false

container_environment = [
  {
    name  = "string_var"
    value = "I am a string"
  },
  {
    name  = "true_boolean_var"
    value = true
  },
  {
    name  = "false_boolean_var"
    value = false
  },
  {
    name  = "integer_var"
    value = 42
  }
]

container_port_mappings = [
  {
    containerPort = 8080
    hostPort      = 8080
    protocol      = "tcp"
  },
  {
    containerPort = 443
    hostPort      = 443
    protocol      = "udp"
  }
]

github_oauth_token = "7b35468f84a37ca9eac7575fd1bdde962845c4d8"

github_webhooks_token = "7b35468f84a37ca9eac7575fd1bdde962845c4d8"

repo_owner = "nellmedina"
repo_name = "springboot-service-1"
branch = "master"
build_image = "aws/codebuild/standard:2.0"
build_compute_type = "BUILD_GENERAL1_SMALL"

build_timeout = 60

poll_source_changes = true
privileged_mode = true
image_repo_name = "springboot-service-1"
image_tag = "latest"

webhook_enabled = true
s3_bucket_force_destroy = true

environment_variables = [
  {
    name  = "APP_URL"
    value = "https://app.example.com"
  },
  {
    name  = "COMPANY_NAME"
    value = "Cloud Posse"
  },
  {
    name  = "TIME_ZONE"
    value = "America/Los_Angeles"

  }
]
