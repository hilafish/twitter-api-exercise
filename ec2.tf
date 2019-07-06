##################################################################################
# RESOURCES
##################################################################################

data "aws_ami" "centos" {
owners      = ["679593333241"]
most_recent = true

  filter {
      name   = "name"
      values = ["CentOS Linux 7 x86_64 HVM EBS *"]
  }

  filter {
      name   = "architecture"
      values = ["x86_64"]
  }

  filter {
      name   = "root-device-type"
      values = ["ebs"]
  }
}


data "template_file" "cron-job" {
  template = "${file("${path.module}/config/templates/cron-job.tpl")}"

  vars {
    mongo_ip = "172.31.27.24"
  }
}

data "template_file" "twitter_streamer" {
  template = "${file("${path.module}/config/templates/twitter_streamer.py.tpl")}"

  vars {
    mongo_ip = "172.31.27.24"
  }
}


resource "aws_instance" "Twitter_Stack" {
  ami                    = "${data.aws_ami.centos.id}"
  instance_type          = "t2.small"
  private_ip             = "172.31.27.24"
  vpc_security_group_ids = ["${aws_security_group.Twitter-SG.id}"]
  key_name               = "${var.gen_key_name}"
  availability_zone      = "us-east-1a"

  connection {
    user        = "centos"
    private_key = "${tls_private_key.env_ssh_key.private_key_pem}"
  }

  provisioner "file" {
    source      = "${path.module}/twitter-playbook"
    destination = "/tmp"
  }

  provisioner "file" {
    source      = "${path.module}/services"
    destination = "/tmp"
  }

  provisioner "file" {
    content     = "${data.template_file.cron-job.rendered}"
    destination = "/tmp/services/puller/cron-job"
  }

  provisioner "file" {
    content     = "${data.template_file.twitter_streamer.rendered}"
    destination = "/tmp/services/streamer/twitter_streamer.py"
  }


  provisioner "remote-exec" {
    inline = [
      "sleep 30",
      "sudo yum update -y",
      "sudo yum upgrade -y",
      "sudo yum install -y python yum-utils device-mapper-persistent-data lvm2",
      "sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo",
      "sudo yum install -y docker-ce docker-ce-cli containerd.io",
      "sudo systemctl start docker",
      "sudo usermod -aG docker centos",
      "sudo yum install -y epel-release",
      "sudo yum install -y python-pip",
      "sudo yum install -y ansible",
      "sudo mkdir -p /etc/ansible/playbooks/twitter-playbook/",
      "sudo mv /tmp/twitter-playbook/main.yml /etc/ansible/playbooks/twitter-playbook/",
      "sudo mv /tmp/twitter-playbook/hosts /tmp/twitter-playbook/roles /etc/ansible/",
      "sudo mv /tmp/services /opt/",
      "ansible-playbook --connection=local --inventory /etc/ansible/hosts /etc/ansible/playbooks/twitter-playbook/main.yml"
    ]
  }

  tags {
    Name = "Twitter_Stack"
    Project = "Twitter-Exercise"
  }
}
