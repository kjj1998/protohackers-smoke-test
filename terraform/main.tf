provider "aws" {
  region = "ap-southeast-1"
}

data "aws_ami" "aws_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "protohacker_server" {
  ami           = data.aws_ami.aws_linux.id
  instance_type = "t3.micro"

  key_name = "jjkoh-mbp-aws"

  vpc_security_group_ids      = [aws_security_group.protohackers-smoke-test-security-group.id]
  subnet_id                   = module.vpc.public_subnets[0]
  availability_zone           = "ap-southeast-1a"
  associate_public_ip_address = true

  root_block_device {
    volume_size           = 10
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "protohackers-smoke-test"
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.6.0"

  name = "protohackers-smoke-test-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  private_subnets = ["10.0.0.0/18", "10.0.64.0/18"]
  public_subnets  = ["10.0.128.0/18", "10.0.192.0/18"]

  enable_dns_hostnames = true

  create_igw         = true
  enable_nat_gateway = false
  single_nat_gateway = false

}

resource "aws_security_group" "protohackers-smoke-test-security-group" {
  name        = "protohackers_smoke_test_security_group"
  description = "Allow ssh, inbound TCP on port 8090 and all outbound TCP requests"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "protohackers smoke test security group+"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.protohackers-smoke-test-security-group.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 8090
  ip_protocol = "tcp"
  to_port     = 8090
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.protohackers-smoke-test-security-group.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound_traffic" {
  security_group_id = aws_security_group.protohackers-smoke-test-security-group.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}
