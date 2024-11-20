terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_sfn_state_machine" "deployment" {
  name     = "frontend-discovery-deployment"
  role_arn = aws_iam_role.step_functions_role.arn

  definition = jsonencode({
    Comment = "Frontend Discovery Deployment State Machine"
    StartAt = "InitializeDeployment"
    States = {
      "InitializeDeployment" = {
        Type = "Pass"
        Next = "ValidateInput"
      }
      "ValidateInput" = {
        Type = "Choice"
        Choices = [
          {
            Variable = "$.deploymentId"
            IsPresent = true
            Next = "ProcessDeployment"
          }
        ],
        Default = "FailDeployment"
      }
      "ProcessDeployment" = {
        Type = "Task"
        Resource = "arn:aws:states:::dynamodb:updateItem"
        Parameters = {
          TableName = var.deployment_store_name
          Key = {
            deploymentId = { S = "$.deploymentId" }
          }
          UpdateExpression = "SET deploymentStatus = :status"
          ExpressionAttributeValues = {
            ":status" = { S = "IN_PROGRESS" }
          }
        }
        Next = "WaitForCompletion"
      }
      "WaitForCompletion" = {
        Type = "Wait"
        Seconds = 30
        Next = "CheckDeploymentStatus"
      }
      "CheckDeploymentStatus" = {
        Type = "Task"
        Resource = "arn:aws:states:::dynamodb:getItem"
        Parameters = {
          TableName = var.deployment_store_name
          Key = {
            deploymentId = { S = "$.deploymentId" }
          }
        }
        Next = "EvaluateStatus"
      }
      "EvaluateStatus" = {
        Type = "Choice"
        Choices = [
          {
            Variable = "$.Item.deploymentStatus.S"
            StringEquals = "COMPLETED"
            Next = "CompleteDeployment"
          },
          {
            Variable = "$.Item.deploymentStatus.S"
            StringEquals = "FAILED"
            Next = "FailDeployment"
          }
        ],
        Default = "WaitForCompletion"
      }
      "CompleteDeployment" = {
        Type = "Pass"
        End = true
      }
      "FailDeployment" = {
        Type = "Pass"
        End = true
      }
    }
  })
}

resource "aws_iam_role" "step_functions_role" {
  name = "frontend-discovery-step-functions"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "step_functions" {
  name = "frontend-discovery-step-functions-policy"
  role = aws_iam_role.step_functions_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:UpdateItem"
        ]
        Resource = [
          var.deployment_store_arn,
          var.frontend_store_arn
        ]
      }
    ]
  })
}