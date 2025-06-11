variable "pipeline_name" {}
variable "artifact_store_bucket" {}
variable "github_repo" {}
variable "github_branch" {}    
variable "github_token_secret_name" {
  description = "The name of the GitHub token stored in AWS Secrets Manager"
  type        = string
  default = "github-token"
}
variable "codebuild_project_name" {}
variable "codedeploy_app" {
  default = "my-deploy-app"
}

variable "codedeploy_group" {
  default = "my-deployment-group"
}