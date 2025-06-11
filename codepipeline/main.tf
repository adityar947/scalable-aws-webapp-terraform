resource "aws_s3_bucket" "artifact_store" {
  bucket = var.artifact_store_bucket
  force_destroy = true
}

data "aws_secretsmanager_secret_version" "github_token" {
  secret_id = var.github_token_secret_name
}

resource "aws_iam_role" "codebuild_service_role" {
  name = "${var.pipeline_name}-codebuild-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "codebuild.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "codebuild_logging_policy" {
  name = "codebuild-logging-policy"
  role = aws_iam_role.codebuild_service_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:us-east-1:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "codebuild_artifact_access" {
  name = "codebuild-s3-access"
  role = aws_iam_role.codebuild_service_role.id # Change to your actual role

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject"
        ],
        Resource = "arn:aws:s3:::my-artifact-bucket12345123/*"
      }
    ]
  })
}

data "aws_caller_identity" "current" {}


resource "aws_codebuild_project" "build_project" {
  name          = var.codebuild_project_name
  description   = "CodeBuild project for building code"
  service_role  = aws_iam_role.codebuild_service_role.arn
  artifacts {
    type = "CODEPIPELINE"
  }
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
  }
  source {
    type            = "CODEPIPELINE"
    buildspec       = "buildspec.yml"
  }
}

resource "aws_codedeploy_app" "app" {
  name = "my-deploy-app"
  compute_platform = "Server"
}

resource "aws_codedeploy_deployment_group" "deploy_group" {
  app_name              = aws_codedeploy_app.app.name
  deployment_group_name = "my-deployment-group"
  service_role_arn      = aws_iam_role.codedeploy_service_role.arn
  deployment_config_name = "CodeDeployDefault.AllAtOnce"

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "Server-1"
    }

    # ec2_tag_filter {
    #   key   = "Name"
    #   type  = "KEY_AND_VALUE"
    #   value = "Server-2"
    # }

    # ec2_tag_filter {
    #   key   = "Name"
    #   type  = "KEY_AND_VALUE"
    #   value = "Server-3"
    # }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}


resource "aws_codepipeline" "this" {
  name     = var.pipeline_name
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = var.artifact_store_bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner      = split("/", var.github_repo)[0]
        Repo       = split("/", var.github_repo)[1]
        Branch     = var.github_branch
        OAuthToken = data.aws_secretsmanager_secret_version.github_token.secret_string
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = var.codebuild_project_name
      }
    }
  }
  stage {
    name = "Deploy"

    action {
      name             = "CodeDeploy"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "CodeDeploy"
      input_artifacts  = ["build_output"]
      version          = "1"

      configuration = {
        ApplicationName     = aws_codedeploy_app.app.name
        DeploymentGroupName = aws_codedeploy_deployment_group.deploy_group.deployment_group_name
      }
    }
  }

}

resource "aws_iam_role" "codepipeline_role" {
  name = "${var.pipeline_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "codepipeline.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "${var.pipeline_name}-policy"
  role = aws_iam_role.codepipeline_role.id

  policy = data.aws_iam_policy_document.pipeline_policy.json
}

data "aws_iam_policy_document" "pipeline_policy" {
  statement {
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
      "s3:*"
    ]

    resources = ["*"]
  }
  statement {
    actions = [
      "codedeploy:CreateDeployment",
      "codedeploy:GetDeployment",
      "codedeploy:GetDeploymentConfig",
      "codedeploy:RegisterApplicationRevision"
    ]
    resources = [
      "arn:aws:codedeploy:us-east-1:${data.aws_caller_identity.current.account_id}:application:${var.codedeploy_app}",
      "arn:aws:codedeploy:us-east-1:${data.aws_caller_identity.current.account_id}:deploymentgroup:${var.codedeploy_app}/${var.codedeploy_group}",
      "arn:aws:codedeploy:us-east-1:${data.aws_caller_identity.current.account_id}:deploymentconfig:CodeDeployDefault.AllAtOnce"

    ]
  }
}

resource "aws_iam_role" "codedeploy_service_role" {
  name = "CodeDeployServiceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "codedeploy.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codedeploy_role_policy" {
  role       = aws_iam_role.codedeploy_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}


resource "aws_iam_role_policy" "codedeploy_access" {
  name = "AllowCodeDeployAccess"
  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "codedeploy:CreateDeployment",
          "codedeploy:GetApplication",
          "codedeploy:GetApplicationRevision",
          "codedeploy:GetDeployment",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:RegisterApplicationRevision"
        ],
        Resource = [
          "arn:aws:codedeploy:us-east-1:783764602003:application:my-deploy-app",
          "arn:aws:codedeploy:us-east-1:783764602003:deploymentgroup:my-deploy-app/my-deployment-group",
          "arn:aws:codedeploy:us-east-1:783764602003:deploymentconfig:CodeDeployDefault.AllAtOnce"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "pipeline_codedeploy" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployFullAccess"
}