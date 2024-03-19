
data "aws_ami" "amazon-linux-2" {
 most_recent = true


 filter {
   name   = "owner-alias"
   values = ["amazon"]
 }


 filter {
   name   = "name"
   values = ["amzn2-ami-hvm*"]
 }
}


resource "aws_instance" "test" {

 ami                         = "${data.aws_ami.amazon-linux-2.id}"
 associate_public_ip_address = false
 instance_type               = "t2.micro"
 vpc_security_group_ids      = ["${aws_security_group.instance.id}"]
 subnet_id                   = "${element(module.vpc.private_subnets, 0)}"
 user_data = <<EOF
#!/bin/bash
sudo su
# install httpd (Linux 2 version)
yum update -y
yum install -y httpd.x86_64
systemctl start httpd.service
systemctl enable httpd.service
echo "Hello World from $(hostname -f)" > /var/www/html/index.html
EOF

}