output "instance_profile_name" {
  description = "The name of the instance profile"
  value       = aws_iam_instance_profile.instance_profile.name
}
