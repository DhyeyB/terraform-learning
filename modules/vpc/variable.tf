variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public subnet cidr value"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "private subnet cidr value"
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones"
}