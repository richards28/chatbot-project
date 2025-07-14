resource "aws_lambda_function" "faq_handler" {
  filename         = "lambda/function.zip"
  function_name    = "${var.project_prefix}_faq_handler"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "index.handler"
  runtime          = "python3.x"
  source_code_hash = filebase64sha256("lambda/function.zip")
  timeout          = 10

  environment {
    variables = {
      FAQ_TABLE     = aws_dynamodb_table.faq.name
      FALLBACK_TABLE = aws_dynamodb_table.fallback_logs.name
      SUPPORT_EMAIL = "richirocks96@gmail.com"
    }
  }
}
