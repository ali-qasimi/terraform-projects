variable "project" {
    type = string
}

variable "ssh_keypair" {
    type = string
    default = "KMS-key-ARN-Dummy"
}

variable "vpc" {
    type = any
}

variable "sg" {
    type = any
}