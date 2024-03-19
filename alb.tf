resource "aws_lb" "service" {

  name               = "main-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.service_alb.id]
  subnets            = module.vpc.public_subnets
 
  enable_deletion_protection = false
}
 
resource "aws_alb_target_group" "service" {

  name        = "main-alb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"
 
  health_check {
   healthy_threshold   = "3"
   interval            = "30"
   protocol            = "HTTP"
   matcher             = "200,302"
   timeout             = "3"
   path                = "/"
   unhealthy_threshold = "2"
  }
}

resource "aws_alb_listener" "service_http" {

  load_balancer_arn = aws_lb.service.id
  port              = 80
  protocol          = "HTTP"

#   default_action {
      
#           type             = "forward"
#           target_group_arn = aws_alb_target_group.service.arn
#         }      

  default_action {      
         type = "redirect"

         redirect {
         port        = 443
         protocol    = "HTTPS"
         status_code = "HTTP_301"
         }
     
     }
}

resource "aws_alb_listener" "service_https" {

  load_balancer_arn = aws_lb.service.id
  port              = 443
  protocol          = "HTTPS"
 
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:us-west-1:488144151286:certificate/82bbed52-083b-422b-abc9-4cd226ad6084"
 
  default_action {
    target_group_arn = aws_alb_target_group.service.id
    type             = "forward"
  }
}


resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = aws_alb_target_group.service.arn
  target_id        = aws_instance.test.id
  port             = 80
}

resource "aws_lb_listener_rule" "redirect_site" {
  listener_arn = aws_alb_listener.service_http.arn

  action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    host_header {
      values = ["test.chainomi.link"]
    }
  }
}
