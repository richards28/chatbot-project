resource "aws_iam_role" "lambda_exec" {
  name = "${var.project_prefix}_lambda_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_exec.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem"
        ],
        Effect = "Allow",
        Resource = [
          aws_dynamodb_table.faq.arn,
          aws_dynamodb_table.fallback_logs.arn
        ]
        {
        "Effect": "Allow",
        "Principal": { "Service": "lex.amazonaws.com" },
        "Action": "lambda:InvokeFunction"
        }
      },
      {
        Action = "ses:SendEmail",
        Effect = "Allow",
        Resource = "*"
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect = "Allow",
        Resource = "*"
      }
    ]
  })
}

