##################################################################################
# Security Groups
##################################################################################


resource "aws_security_group" "Twitter-SG" {
  name   = "Twitter-SG"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "Twitter-SG"
    Project = "Twitter-Exercise"
  }
}
