resource "aws_s3_bucket" "cmd-inj-bucket" {
  bucket = "cr-cmdinj-bucket-s3bucket"
  tags = {
    Name        = "cr-cmdinj-bucket-s3bucket"
  }
}


resource "aws_s3_bucket_object" "resource" {
  bucket = "${aws_s3_bucket.cmd-inj-bucket.id}"
  key = "flag.txt"
  source = "./flag/flag.txt"
  tags = {
    Name = "cr-cmd_inj-flag"
  }
}