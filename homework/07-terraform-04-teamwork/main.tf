provider "aws" {
   region = "eu-north-1"
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "single-instance"

  ami                    = "ami-ebd02392"
  instance_type          = "t2.micro"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}