data "aws_lb" "beanstalk_alb" {
  arn = aws_elastic_beanstalk_environment.ktlog.load_balancers[0]
}

output "beanstalk_alb_dns_name" {
  value = data.aws_lb.beanstalk_alb.dns_name
}

output "beanstalk_alb_zone_id" {
  value = data.aws_lb.beanstalk_alb.zone_id
}

# output "beanstalk_security_group_id" {
#   value = aws_security_group.beanstalk.id
# }
