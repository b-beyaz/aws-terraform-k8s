resource "aws_security_group" "alb" {
  name        = "k3s-gitops-alb"
  description = "ALB security group"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "k3s-gitops-alb-sg"
  }
}

resource "aws_security_group" "node" {
  name        = "k3s-gitops-node"
  description = "k3s node security group"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "k3s-gitops-node-sg"
  }
}

# ALB: internetten 80
resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

# ALB: node'lara 30080
resource "aws_vpc_security_group_egress_rule" "alb_to_nodes" {
  security_group_id            = aws_security_group.alb.id
  referenced_security_group_id = aws_security_group.node.id
  ip_protocol                  = "tcp"
  from_port                    = 30080
  to_port                      = 30080
}

# Node: node'lar kendi aralarında (API, kubelet, overlay ağ)
resource "aws_vpc_security_group_ingress_rule" "node_self" {
  security_group_id            = aws_security_group.node.id
  referenced_security_group_id = aws_security_group.node.id
  ip_protocol                  = "-1"
}

# Node: internete çıkış
resource "aws_vpc_security_group_egress_rule" "node_all" {
  security_group_id = aws_security_group.node.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "node_from_alb" {
  security_group_id            = aws_security_group.node.id
  referenced_security_group_id = aws_security_group.alb.id
  ip_protocol                  = "tcp"
  from_port                    = 30080
  to_port                      = 30080
}