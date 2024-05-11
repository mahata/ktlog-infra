output "beanstalk_alb_dns_name" {
  value = data.aws_lb.beanstalk_alb.dns_name
}

output "beanstalk_alb_zone_id" {
  value = data.aws_lb.beanstalk_alb.zone_id
}
