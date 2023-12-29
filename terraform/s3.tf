resource "aws_s3_bucket" "main" {
  bucket = "joonhun_cmd-inj_bucket"

  tags = {
    Name        = "joonhun_cmd-inj_bucket"
  }
}