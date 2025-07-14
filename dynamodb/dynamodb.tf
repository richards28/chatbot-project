resource "aws_dynamodb_table" "faq" {
  name           = "${var.project_prefix}_faq"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "Intent"

  attribute {
    name = "Intent"
    type = "S"
  }
}

resource "aws_dynamodb_table" "fallback_logs" {
  name           = "${var.project_prefix}_unanswered"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "Timestamp"

  attribute {
    name = "Timestamp"
    type = "S"
  }
}
