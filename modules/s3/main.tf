resource "aws_s3_bucket" "main" {
  bucket = "${var.namespace}-${var.bucket_name}"

  tags = {
    Name = "${var.namespace}-${var.bucket_name}"
  }
}

resource "aws_s3_bucket_cors_configuration" "main" {
  bucket = aws_s3_bucket.main.id
  #TODO: Edit this when phoenix app up to only allow that domain?
  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
  }
}

resource "aws_s3_bucket_policy" "public_read_policy_assets" {
  bucket = aws_s3_bucket.main.id
  policy = data.aws_iam_policy_document.allow_public_access_to_assets.json

}

data "aws_iam_policy_document" "allow_public_access_to_assets" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
    resources = ["${aws_s3_bucket.main.arn}/static/*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}
