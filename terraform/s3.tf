resource "aws_s3_bucket" "cmd-inj-bucket" {
  bucket = "cmd-inj-bucket"
  

  tags = {
    Name        = "cmd-inj-bucket"
  }
}


resource "aws_s3_bucket_object" "resource" {
  bucket = "${aws_s3_bucket.cmd-inj-bucket.id}"
  key = "flag.txt"
  source = "../files/flag.txt"
  tags = {
    Name = "cmd-inj-flag"
  }
}