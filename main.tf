module "vpc" {
  source          = "./vpc"
  cidr_block      = "10.0.0.0/16"
  vpc_name        = "MyVPC"
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  availability_zones = ["us-east-1a", "us-east-1b"]
}

module "iam" {
  source                = "./iam"
  iam_role_name         = "EC2IAMRoleTrends"
  instance_profile_name = "EC2InstanceProfileTrends"
}

module "security_groups" {
  source             = "./security_groups"
  vpc_id             = module.vpc.vpc_id
  ssh_ip             = var.ssh_ip
  http_ip            = var.http_ip
  https_ip           = var.https_ip
  anywhere_ipv4      = var.anywhere_ipv4
  custom_port_subnet = var.custom_port_subnet
}

module "ec2" {
  source                     = "./ec2"
  ami                        = var.ami
  key_name                   = var.key_name
  subnet_id_1                = module.vpc.public_subnet_ids[0]
  subnet_id_2                = module.vpc.public_subnet_ids[1]
  iam_instance_profile_name  = module.iam.instance_profile_name
  security_group_ids_server1 = [module.security_groups.server1_sg_id] # Wrap in a list
  security_group_ids_server2 = [module.security_groups.server2_sg_id] # Wrap in a list
  security_group_ids_server3 = [module.security_groups.server3_sg_id] # Wrap in a list
}

module "target_group" {
  source             = "./target_group"
  name               = "my-new-tg"
  port               = 80
  protocol           = "HTTP"
  vpc_id             = module.vpc.vpc_id
  health_check_path  = "/"
}

resource "aws_lb_target_group_attachment" "example_attachment" {
  target_group_arn = module.target_group.target_group_arn
  target_id        = module.ec2.target_group_id
  port             = 80
}

module "alb" {
  source             = "./alb"
  name               = "my-alb"
  security_groups    = [module.security_groups.server1_sg_id]
  subnets           = module.vpc.public_subnet_ids
  target_group_arn   = module.target_group.target_group_arn
}

module "asg" {
  source            = "./asg"
  name              = "my-asg"
  ami_id            = "ami-005fc0f236362e99f"
  instance_type     = "t3.micro"
  security_groups   = [module.security_groups.server1_sg_id]
  desired_capacity  = 2
  min_size          = 1
  max_size          = 3
  subnets           = module.vpc.public_subnet_ids
  target_group_arn  = module.target_group.target_group_arn
}

module "route53" {
  source       = "./route53"
  domain_name  = "example.com"
  record_name  = "www.example.com"
  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id = module.alb.alb_zone_id
}

module "pipeline" {
  source                  = "./codepipeline"
  pipeline_name           = "my-demo-pipeline"
  artifact_store_bucket   = "my-artifact-bucket12345123"
  github_repo             = "adityar947/angular-app-aws-cicd"
  github_branch           = "master"
  github_token_secret_name= "github-token"
  codebuild_project_name  = "my-codebuild-project"
}