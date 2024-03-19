#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httd
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
chmod 2775 /var/www
echo "<h1>Hello World</h1>" > /var/www/html/index.html