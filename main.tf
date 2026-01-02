resource "aws_vpc" "myownec2vm" {
  cidr_block = "192.168.0.0/16"
  tags={
    Name="Myownec2vpc"
  }
}
resource "aws_subnet" "myownec2sub" {
    count = local.subnets_count
  vpc_id = aws_vpc.myownec2vm.id
  cidr_block = var.myownec2info.subec2cidr[count.index]
  availability_zone = var.myownec2info.subec2az[count.index]
  tags = {
    Name=var.myownec2info.subec2name[count.index]
  }
}

resource "aws_route_table" "myownec2route" {
  vpc_id=aws_vpc.myownec2vm.id
  route{
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myownec2igw.id
  }
    tags = {
      Name="myownec2route"
    }
}
resource "aws_internet_gateway" "myownec2igw" {
  vpc_id = aws_vpc.myownec2vm.id
  tags = {
    Name="myownec2igw"
  }
}

resource "aws_route_table_association" "myrouteassociation" {
    count = local.subnets_count
  route_table_id = aws_route_table.myownec2route.id
  subnet_id = aws_subnet.myownec2sub[count.index].id
}

resource "aws_security_group" "myownec2sg" {
  name = "myownec2securitygroup"
  description = "All Network Securitygroup"
  vpc_id = aws_vpc.myownec2vm.id
}

resource "aws_vpc_security_group_ingress_rule" "myownec2sgrules" {
  security_group_id = aws_security_group.myownec2sg.id
  from_port = 22
  to_port = 22
  ip_protocol="tcp"
  cidr_ipv4= "0.0.0.0/0"
}

resource "aws_key_pair" "myownec2key" {
    key_name = "mysshownkey"
    public_key = file("~/id_ed25519.pub")
}

data "aws_ami" "myownec2ami"{
  filter {
    name="myownec2ami"
    values=["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
  owners = ["099720109477"]
}

resource "aws_instance" "myownec2" {
    ami = data.aws_ami.myownec2ami.id
    instance_type = "t3.micro"
    key_name = aws_key_pair.myownec2key.key_name
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.myownec2sg.id]
    tags = {
      Name="myownterraformec2"
    }
}