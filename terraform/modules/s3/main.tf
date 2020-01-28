#NOTE THIS ASSUMES PRIVATE BUCKETS
resource "aws_s3_bucket" "bucket" {
  bucket = "${var.bucket_name}"
  acl    = "private"
}
