variable "aws_region" {
    default = "ap-northeast-1"
}

variable "instance_type" {
    default = "t3.micro"
}

variable "ami_id" {
    default = "ami-0244ef75e95122fd9" # latest ubuntu ami in ap-northeast-1
}

variable "tags" {
    type = map(string)
    default = {
        Name = "Industry-DevOps-SAP"
        Owner = "Sree"
    }
}