resource "random_password" "k3s_token" {
  length  = 48
  special = false
}

resource "aws_instance" "control_plane" {
  ami                    = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.node.id]
  iam_instance_profile   = aws_iam_instance_profile.node.name

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  user_data_replace_on_change = true
  user_data                   = <<-EOF
    #!/bin/bash
    curl -sfL https://get.k3s.io | K3S_TOKEN=${random_password.k3s_token.result} INSTALL_K3S_EXEC="server --disable traefik" sh -
  EOF

  tags = {
    Name = "k3s-control-plane"
  }
}

resource "aws_instance" "worker" {
  ami                    = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.public_b.id
  vpc_security_group_ids = [aws_security_group.node.id]
  iam_instance_profile   = aws_iam_instance_profile.node.name

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  user_data_replace_on_change = true
  user_data                   = <<-EOF
    #!/bin/bash
    curl -sfL https://get.k3s.io | K3S_URL=https://${aws_instance.control_plane.private_ip}:6443 K3S_TOKEN=${random_password.k3s_token.result} sh -
  EOF

  tags = {
    Name = "k3s-worker"
  }
}