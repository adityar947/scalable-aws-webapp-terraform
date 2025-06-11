resource "aws_iam_role" "ec2_role_trends" {
  name = var.iam_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = var.instance_profile_name
  role = aws_iam_role.ec2_role_trends.name
}

resource "aws_iam_role_policy" "ec2_codedeploy_s3_policy" {
  name = "AllowS3AndCodeDeploy"
  role = aws_iam_role.ec2_role_trends.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "AllowS3GetList",
        Effect   = "Allow",
        Action   = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::my-artifact-bucket12345123",
          "arn:aws:s3:::my-artifact-bucket12345123/*"
        ]
      },
      {
        Sid      = "AllowCodeDeploy",
        Effect   = "Allow",
        Action   = [
          "codedeploy:PutLifecycleEventHookExecutionStatus",
          "codedeploy:GetDeployment",
          "codedeploy:GetDeploymentGroup",
          "codedeploy:ListDeploymentGroups",
          "codedeploy:GetApplicationRevision"
        ],
        Resource = "*"
      }
    ]
  })
}
