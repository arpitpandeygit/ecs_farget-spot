terraform {
  backend "s3" {
    bucket = "arpit-ecs-fargate-spot-tf-state"
    key    = "state/terraform.tfstate"
    region = "us-east-1"
  }
}
