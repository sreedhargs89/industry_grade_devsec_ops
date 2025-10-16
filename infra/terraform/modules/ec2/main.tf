resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  associate_public_ip_address = true

  tags = var.tags

  monitoring = true

  lifecycle {
    create_before_destroy = true
  }
}
