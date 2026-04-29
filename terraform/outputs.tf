output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_id" {
  value = aws_subnet.public.id
}

output "security_group_id" {
  value = aws_security_group.main_sg.id
}

output "bucket_name" {
  value = aws_s3_bucket.project_bucket.bucket
}

output "ec2_public_ip" {
  value = aws_instance.llm_ec2.public_ip
}
