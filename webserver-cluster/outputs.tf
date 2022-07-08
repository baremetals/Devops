output "alb_dns_name" {
  value = aws_lb.bm-test.dns_name
  description = "The public ip of the instance"
}