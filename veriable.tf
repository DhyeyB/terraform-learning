variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}

variable "region" {
  type = string
}

variable "ingress_ports" {
  description = "Inbound ports to be opened."
  type        = list(number)
  default     = [22, 80]
}