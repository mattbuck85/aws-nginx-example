
resource "aws_key_pair" "deployer" {
  key_name = "deployer-key"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_security_group" "load_balancing" {

  name = "load-balancing"
  description = "Enable SSH and a web port"
  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
resource "aws_security_group" "computing" {

  name = "computing"
  description = "Enable SSH and a web port"
  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "nginx_load_balancer" {

  connection {
    user = "centos"
    private_key = "${file(var.private_key_path)}"
  }

  ami           = "ami-ae7bfdb8"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.load_balancing.id}"]
  key_name = "${aws_key_pair.deployer.id}"
  subnet_id = "${aws_subnet.default.id}"

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y install epel-release",
      "sudo yum -y install nginx"
    ]
  }
  tags {
    group = "load_balancer"
  }

  lifecycle{
    create_before_destroy = "True"
  }
}

resource "aws_instance" "nginx_node"{

  connection {
    user = "centos"
    private_key = "${file(var.private_key_path)}"
  }

  ami = "ami-ae7bfdb8"
  instance_type = "t2.micro"
  count = "3"
  vpc_security_group_ids = ["${aws_security_group.computing.id}"]
  key_name = "${aws_key_pair.deployer.id}"
  subnet_id = "${aws_subnet.default.id}"

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y install epel-release",
      "sudo yum -y install nginx",
      "sudo mkdir /opt/http"
    ]
  }

  tags {
    group = "compute"
  }

  lifecycle {
    create_before_destroy = "True"
  }
}
