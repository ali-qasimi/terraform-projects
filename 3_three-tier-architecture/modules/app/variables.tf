variable "project" {
    type = string
    default = "three-tier-app"
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

variable "db_config" {
    type = object(
        {
            user = string
            password = string
            database = string
            hostname = string
            port = string
        }
    )
}
