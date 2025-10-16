variable "region" {
  type    = string
  default = "ap-south-1"
}
variable "key_name"    { 
    type = string
    default = "sree-devops-key-mumbai"
}
variable "ami_id"      { 
    type = string
    default = "ami-0088a4dc01f0b276f"
}
variable "tags" {
  type    = map(string)
  default = { Project = "k8s-cluster" }
}