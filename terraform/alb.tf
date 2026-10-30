resource "aws_lb" "main" {
  name               = "k3s-gitops-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

resource "aws_lb_target_group" "nodeport" {
  name     = "k3s-gitops-tg"
  port     = 30080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path    = "/health"
    matcher = "200"
  }
}

resource "aws_lb_target_group_attachment" "control_plane" {
  target_group_arn = aws_lb_target_group.nodeport.arn
  target_id        = aws_instance.control_plane.id
  port             = 30080
}

resource "aws_lb_target_group_attachment" "worker" {
  target_group_arn = aws_lb_target_group.nodeport.arn
  target_id        = aws_instance.worker.id
  port             = 30080
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nodeport.arn
  }
}

output "alb_dns_name" {
  value = aws_lb.main.dns_name
}