# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "MyVPC"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  
  tags = {
    Name = "MyIGW"
  }
}

# Create Subnet A (Web Tier)
resource "aws_subnet" "subnet_a" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = true  # Enable public IP assignment for instances in this subnet

  tags = {
    Name = "SubnetA"
  }
}

# Associate Subnet A with the custom route table
resource "aws_route_table_association" "subnet_a_association" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.my_route_table.id
}



# Create a Route Table
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  
  tags = {
    Name = "MyRouteTable"
  }
}

# Create a route in the Route Table to send all traffic to the Internet Gateway
resource "aws_route" "internet_gateway_route" {
  route_table_id         = aws_route_table.my_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

# Create Security Group
resource "aws_security_group" "my_sg" {
  name        = "MySecurityGroup"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.my_vpc.id
  
  ingress {
    from_port   = 0  # Allow all inbound traffic
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0  # Allow all outbound traffic
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Create EC2 instance
resource "aws_instance" "web_ec2_instance" {
  ami                    = "ami-08116b9957a259459"  # Replace with your desired AMI ID for web tier
  key_name               = "demo"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet_a.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  
  tags = {
    Name = "WebEC2Instance"
  }
}

# Output the public IP address of the EC2 instance
output "public_ip_address" {
  value = aws_instance.web_ec2_instance.public_ip
}
