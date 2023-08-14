# create EC2 instance & bootstrap httpd web server
resource "aws_instance" "web1" {

  ami                         = data.aws_ssm_parameter.ami-web.value
  instance_type               = "t3.small"
  associate_public_ip_address = true
  key_name                    = aws_key_pair.key_web.key_name
  vpc_security_group_ids      = [aws_security_group.sg1.id]
  subnet_id                   = aws_subnet.sub1.id

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }
    inline = [
      "sudo yum -y install httpd && sudo systemctl start httpd",
      "echo '<h1><center>Test Website - Bogdan & Terraform = LOVE</center></h1>' > index.html",
      "sudo mv index.html /var/www/html/"
    ]
  }

  tags = {
    Name = "web1"
  }
}

output "web_srv_public_ip_address" {
  value = aws_instance.web1.public_ip
}
