variable "region" {
    description = "an AWS region of your choice"
    default     = "ap-southeast-2a"
    type        = string
}

variable "instance-type" {
    description = "EC2 instance type of choice"
    default     = "t2.micro"
    type        = string
}
