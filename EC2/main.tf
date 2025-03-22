resource "aws_instance" "my_ec2" {
  ami = "ami-063d43db0594b521b"
  instance_type = "t3.small"
  key_name = aws_key_pair.my_key_pair.key_name
  subnet_id = var.subnet_id
  security_groups = [aws_security_group.my_sg.id]

  user_data = <<-EOF
  #!/bin/bash
  sudo yum update -y
  
  # Install Docker
  sudo dnf install docker -y
  sudo systemctl start docker
  sudo systemctl enable docker
  sudo usermod -aG docker ec2-user
  newgrp docker

  # Install kubectl (Kubernetes command line tool)
  curl -LO "https://dl.k8s.io/release/v1.23.6/bin/linux/amd64/kubectl"
  chmod +x kubectl
  sudo mv kubectl /usr/local/bin/
  
  # Install kubelet and kubeadm (Kubernetes components)
  sudo yum install -y kubelet kubeadm kubectl
  sudo systemctl enable kubelet
  sudo systemctl start kubelet

  # Allow kubectl commands without sudo
  sudo usermod -aG kubelet ec2-user
  
  # Ensure kubectl is executable
  kubectl version --client
EOF


  tags = {
    Name = "MyEC2K8Instance"
  }
}

resource "aws_security_group" "my_sg" {
  name = "my_sg"
  vpc_id = var.vpc_id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "tls_private_key" "my_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "my_key_pair" {
  key_name   = "my_key_pair"
  public_key = tls_private_key.my_key.public_key_openssh
}

resource "local_file" "private_key" {
  content  = tls_private_key.my_key.private_key_pem
  filename = "./my_key_pair.pem"
}
