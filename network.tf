resource "aws_vpc" "myvpc"{
  cidr_block       = "10.0.0.0/27"
  tags = {
    Name = "MyVpc"
  }
}
resource "aws_subnet" "publicsubnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.0.0/28"
  map_public_ip_on_launch=true
  depends_on = [aws_vpc.myvpc]
  tags = {
    Name = "MyPublicSubnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.0.16/28"
  #map_public_ip_on_launch=true
  depends_on = [aws_vpc.myvpc]
  tags = {
    Name = "MyPrivateSubnet"
  }
}

resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id
  depends_on=[aws_vpc.myvpc]
  tags = {
    Name = "myigw"
  }
}

resource "aws_route_table" "mypublicrt" {
  vpc_id = aws_vpc.myvpc.id
  depends_on=[aws_vpc.myvpc,aws_internet_gateway.myigw]
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }
  tags = {
    Name = "MyPublicRt"
  }
}

resource "aws_route_table_association" "mysubnet_route" {
  subnet_id      = aws_subnet.publicsubnet.id
  route_table_id = aws_route_table.mypublicrt.id
  depends_on=[aws_subnet.publicsubnet,aws_route_table.mypublicrt]
}

resource "aws_eip" "myeip" {
	  tags={
		Name="MyEip"
	}
}


resource "aws_nat_gateway" "mynatgw" {
  allocation_id = aws_eip.myeip.id
  subnet_id     = aws_subnet.publicsubnet.id
  tags={
		Name: "MyNatgw"
	}
 depends_on=[aws_eip.myeip,aws_subnet.publicsubnet]
}


resource "aws_route_table" "myprivatert" {
  vpc_id = aws_vpc.myvpc.id
  depends_on=[aws_vpc.myvpc,aws_internet_gateway.myigw,aws_nat_gateway.mynatgw]
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.mynatgw.id
  }
  tags = {
    Name = "MyPrivateRt"
  }
}



resource "aws_route_table_association" "myprivate_subnet_route" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.myprivatert.id
  depends_on=[aws_subnet.private_subnet,aws_route_table.myprivatert]
}
