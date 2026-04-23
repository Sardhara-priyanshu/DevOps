provider "aws" {
	region = "ap-south-1"
}

# Create AWS S3 Bucket...

resource "aws_s3_bucket" "my_bucket" {
	bucket = "priyanshu-terraform-bucket-070905"
}

# File Upload porsion...

resource "aws_s3_object" "file_upload" {
	bucket = aws_s3_bucket.my_bucket.id
	key    = "file.txt"
	source = "file.txt"
}


