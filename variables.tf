# test variable for the can() and regex() functions
variable "container-port-ext1" {
  type    = number
  default = 35000
  validation {
    condition     = can(regex("35000|35001|35002|35003|35004", var.container-port-ext1))
    error_message = "valid port values: 35001-35004"
  }
}

variable "project-name" {
  type    = string
  default = "test"
}

variable "rules" {
  default = [
    {
      port        = 22,
      protocol    = "tcp",
      cidr_blocks = ["0.0.0.0/24"]
    },
    {
      port        = 80,
      protocol    = "tcp",
      cidr_blocks = ["0.0.0.0/0"]
  }]
}
