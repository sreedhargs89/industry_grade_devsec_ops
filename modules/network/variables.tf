variable "vpc_cidr"        { 
    type = string
  default = "10.0.0.0/16"
}
variable "public_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}
variable "tags" {
  type    = map(string)
  default = { Project = "k8s-cluster" }
}
