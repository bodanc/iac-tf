output "web-server-url" {
  description = "Web Server URL"
  value       = join("", ["http://", aws_instance.tf-httpd.public_ip])
}

output "time-date" {
  description = "Date & Time of Execution"
  value       = timestamp()
}
