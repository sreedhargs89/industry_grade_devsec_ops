variable "subnet_id"        { type = string }
variable "key_name"         { type = string } # Use your existing AWS key pair name
variable "instance_type"    { 
    type = string
    default = "t3.medium" 
                }
variable "ami_id"           { type = string } # Ubuntu 22.04 in your region
variable "tags"             { 
    type = map(string) 
    default = { Project = "k8s-cluster" } 
}
variable "control_plane_count" { 
    type = number 
    default = 1 
}
variable "worker_count"        { 
    type = number 
    default = 2 
    }