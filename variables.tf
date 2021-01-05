variable "ami" {
    type = map
    default = {
        "app" = "ami-08684e199bfc3817a"
        "db" = "ami-0c01cb6c44345cc41"
    }
}

variable "keys" {
    type = map
    default = {
        "jared" = "eng74.Jared.aws.key"
    }
}
