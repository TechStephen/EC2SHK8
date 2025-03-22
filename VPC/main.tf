# Creates vpc
resource "aws_vpc" "my_vpc" {
    cidr_block = "10.0.0.0/16" # provide cidr block
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
      name = "MyVPCEC2K8"
    }
}

# Creates public subnet 1 for ec2  (us-east-1a)
resource "aws_subnet" "ec2_public_subnet_1" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true

    tags = {
      Name = "EC2K8PublicSubnet"
    }
}

# Creates internet gateway
resource "aws_internet_gateway" "my_igw" {
    vpc_id = aws_vpc.my_vpc.id
    tags = {
      Name = "MyEC2K8InternetGateway"
    }
}

# Creates route table (needed to connect to igw)
resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.my_vpc.id
    tags = {
      Name = "EC2K8PublicRouteTable"
    }
}

# Creates route connect subnet to internet gateway
resource "aws_route" "public_internet_route" {
    destination_cidr_block = "0.0.0.0/0"
    route_table_id = aws_route_table.public_route_table.id
    gateway_id = aws_internet_gateway.my_igw.id
}

# Connect Load Balancer Public Subnet 1 to Route Table
resource "aws_route_table_association" "lb_public_subnet_association_1" {
  subnet_id = aws_subnet.ec2_public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}