

 # I added this Povider in separate file 

# provider "aws" {t
#   region     = "us-east-1"
#   # access_key = "aws_access_key_id"
#   # secret_key = "aws_secret_access_key"
# }


# resource "aws_instance" "firstServer" {
#   ami = "ami-0ebfd941bbafe70c6"
#   instance_type = "t2.micro"

#   tags = {
#     Name = "Server1-tag"
#   }
# }

resource "aws_instance" "firstServer" {
  ami = var.os_instance_ami
  instance_type = var.os_size

  tags = {
    Name = var.os_name
  }
}

# Creating s3 Bucket
resource "aws_s3_bucket" "bucket" {
  bucket = var.s3_bucket_name
}

# Creating iam user using -var-file parameter in the console
resource "aws_iam_user" "myuser" {
  name= "${var.username}-user"

}