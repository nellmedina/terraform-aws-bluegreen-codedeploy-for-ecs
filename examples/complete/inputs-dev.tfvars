region = "ap-southeast-1"
availability_zones = ["ap-southeast-1a", "ap-southeast-1b"]
vpc_id = "vpc-02e09d5fbf4b98211"
subnet_ids = ["subnet-04676ca5151426d2b", "subnet-053b91915bbcffd18"]

namespace = "nm"
stage = "dev"
name = "bluegreen1"
# attributes  = ["part2"]

tags = {
	"City"    = "Laoag"
	"Purpose" = "Improve-Skill"
}

ecs_launch_type = "FARGATE"
network_mode = "awsvpc"
ignore_changes_task_definition = true
assign_public_ip = true
propagate_tags = "TASK_DEFINITION"
deployment_minimum_healthy_percent = 100
deployment_maximum_percent = 200
deployment_controller_type = "CODE_DEPLOY"
desired_count = 1
task_memory = 1024
task_cpu = 512

container_name = "springboot-service-1"
container_image = ""
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
  }
]

container_port = 8080
container_port_mappings = [
  {
    containerPort = 8080
    hostPort      = 8080
    protocol      = "tcp"
  }
]

internal = false
http_enabled = true
access_logs_enabled = true
alb_access_logs_s3_bucket_force_destroy = true
access_logs_region = "ap-southeast-1"
cross_zone_load_balancing_enabled = true
http2_enabled = true
idle_timeout = 60
ip_address_type = "ipv4"
deletion_protection_enabled = false
deregistration_delay = 15
health_check_path = "/"
health_check_timeout = 10
health_check_healthy_threshold = 2
health_check_unhealthy_threshold = 2
health_check_interval = 15
health_check_matcher = "200-399"

target_group_port = 8080
target_group_target_type = "ip"

authentication_type = ""
unauthenticated_priority = 100
unauthenticated_paths = ["/"]
slow_start = 0
stickiness_enabled = false


github_oauth_token    = "GithubToken"
github_webhooks_token = "GithubToken"

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



auto_rollback_enabled = true
auto_rollback_events  = ["DEPLOYMENT_FAILURE"]
iam_path              = "/service-role/"

