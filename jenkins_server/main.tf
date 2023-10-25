resource "aws_key_pair" "my_keypair" {
    key_name = "jenkins-key"
    public_key = file("~/.ssh/id_rsa.pub")
}


resource "aws_security_group" "my_sg" {
    name = "my security groups"
    description = "open ports 22,443,80,3000, 8080,9000"

    ingress = [
        for port in [ 22, 443, 80, 8080, 9000,3000 ] : {
            description = "ports"
            from_port = port
            to_port = port
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
            ipv6_cidr_blocks = []
            prefix_list_ids = []
            security_groups = []
            self = false
        }
    ]

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        name = "my-sg"
    }
}

resource "aws_instance" "ec2_instance" {
    ami = "ami-0fc5d935ebf8bc3bc"
    instance_type = "t2.large"
    key_name = aws_key_pair.my_keypair.id
    security_groups = [aws_security_group.my_sg.id]
    user_data = templatefile("./install.sh", {})

    tags = {
        name = "jenkins-server"
    }
    root_block_device {
      volume_size = 30
    }
}

