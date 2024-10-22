resource "aws_vpc" "myvpc"{
    cidr_block = var.cidr
    tags={
        Name = "myvpc"
    }
}

resource "aws_subnet" "subnet"{
    count                   = 2
    vpc_id                  = aws_vpc.myvpc.id
    cidr_block              = cidrsubnet(aws_vpc.myvpc.cidr_block,8,count.index)
    availability_zone       = element(["ap-south-1a","ap-south-1b"],count.index)
    map_public_ip_on_launch = true

    tags={
        Name = "myvpc-subnet-${count.index}"
    }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "mvpc-igw"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.myvpc.id

  route{
    gateway_id = aws_internet_gateway.igw.id
    cidr_block = "0.0.0.0/0"
  }

  tags={
    Name = "myvpc-rt"
  }
}

resource "aws_route_table_association" "assoc" {
  count          = 2
  subnet_id      = aws_subnet.subnet[count.index].id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "cluster-sg" {
  name   = "cluster-sg"
  vpc_id = aws_vpc.myvpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags={
    Name = "cluster-sg"
  }
}

resource "aws_security_group" "node-sg" {
  name   = "node-sg"
  vpc_id = aws_vpc.myvpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress{
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags={
    Name = "node-sg"
  }
}

resource "aws_eks_cluster" "cluster" {
  name     = "cluster"
  role_arn = aws_iam_role.cluster-role.arn

  vpc_config {
    subnet_ids         = aws_subnet.subnet[*].id
    security_group_ids = [ aws_security_group.cluster-sg.id ]
  }
}

resource "aws_eks_node_group" "node" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "node"
  node_role_arn   = aws_iam_role.node-role.arn 
  subnet_ids      = aws_subnet.subnet[*].id

  scaling_config{
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }

  instance_types = ["t2.medium"]

  remote_access {
    ec2_ssh_key               = var.ssh
    source_security_group_ids = [ aws_security_group.node-sg.id ]
  }
}

resource "aws_iam_role" "cluster-role" {
  name = "cluster-role"
  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
  }
EOF
}

resource "aws_iam_role_policy_attachment" "clusterpolicy"{
  role       = aws_iam_role.cluster-role.name 
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "node-role" {
  name = "node-role"
  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
   "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
  }
  EOF
}

resource "aws_iam_role_policy_attachment" "nodepolicy"{
  role       = aws_iam_role.node-role.name 
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "cnipolicy"{
  role       = aws_iam_role.node-role.name 
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "registrypolicy"{
  role       = aws_iam_role.node-role.name 
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
