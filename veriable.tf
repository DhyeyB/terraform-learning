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

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public subnet cidr value"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "private subnet cidr value"
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones"
  default     = ["ap-south-1a", "ap-south-1b"]
}