variable "os_instance_ami" {
  type        = string
  default     = "ami-0ebfd941bbafe70c6"
  description = "operating system ami"
}


variable "os_size" {
    type        = string
   default     = "t2.micro"
   description = "t2.micro operating system size"
}

variable "os_name" {
   type        = string
   default     = "TerraformEC2"

}


variable "s3_bucket_name" {
  type = string
  default = "myFirstDemoBucketHasan"
}

variable "username"{
  type= string
}