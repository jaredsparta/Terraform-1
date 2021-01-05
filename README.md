# Terraform and AMI's

![](images/diagram.jpg)

<br>

## What is Terraform
- Terraform is a tool for building, changing, and versioning infrastructure safely and efficiently. Terraform can manage existing and popular service providers as well as custom in-house solutions.
- The infrastructure Terraform can manage includes low-level components such as compute instances, storage, and networking, as well as high-level components such as DNS entries, SaaS features, etc.

[Source](https://www.terraform.io/intro/index.html)


<br>

## Why Terraform

- It is agentless so there is no need to install any extra agents apart from Terraform itself
- It is declarative so all you need to do is declare what state you want the infrastructure and Terraform will do the rest for you
- It is cloud-independent, we can use Terraform for AWS, Azure, etc. 

<br>

## Examples
- In the following, the AMI's used are already provisioned to run the app and the database (via Packer and Ansible)

<br>

### Terraform to create an EC2 instance
- One can create EC2 instances using the resource `aws_instance`
- Documentation can be found [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)
- The following creates the app EC2 instance
```
resource "aws_instance" "nodejs_instance" {
    ami = var.ami["app"]
    instance_type = "t2.micro"
    associate_public_ip_address = true
    key_name = var.keys["jared"]
    vpc_security_group_ids = [ aws_security_group.appSG.id ]
    tags = {
      "Name" = "eng74-jared-terraform-app"
    }
}
```

<br>

### Terraform to create Security groups
- This can be achieved using the resource `aws_security_group`
- Documentation can be found [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)
- The following creates the security group for the database
```
resource "aws_security_group" "dbSG" {
    name = "eng74.jared.SG.db.terraform"
    description = "allows access to app from port 80 anywhere"

    ingress {
        description = "port 27017 access from app"
        from_port = 27017
        to_port = 27017
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "port 22 from home"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        security_groups = [aws_security_group.appSG.id]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
```

<br>

### A more dynamic Terraform
- While we can write key-value pairs explicitly, it is always good to provide more dynamic elements
- We can make use of a separate file containing several variables we can call in our Terraform `main.tf`
    - Variables are used via the keyword `var.<name-of-variable>`
    - `var.<name-of-variable>["<key-name"]` can be used if the variable is a mapping

```
variable "ami" {
    type = map
    default = {
        "app" = "ami-08684e199bfc3817a"
        "db" = "ami-0c01cb6c44345cc41"
    }
}
```

<br>

- One can also use the outputs from previous tasks
- For instance, `main.tf` will create two security groups first. We can then use these newly created security groups as the groups for the EC2 instances that will be created -- all within the same command. How?
    - For any resource, we can call it's variables via `<resource-name>.<identifier>.<variable>`
- Why do it this way?
    - This will save a lot of time as one will no longer need to manually add a security group in AWS


- Example:
    1. The first resource called `appSG` creates the security group for our app instance
    2. Of course since this is a newly-created SG we won't have it's ID to input into the `.tf` file
    3. We can still associate this SG with our app by using the output of it's resource
    4. One can see that in the second resource, the security group being associated to the app is `aws_security_group.appSG.id`, which references the ID of the security group that the first resource creates

```tf
resource "aws_security_group" "appSG" {
    name = "eng74.jared.SG.app.terraform"
    description = "allows access to app from port 80 anywhere"

    ingress {
        description = "port 80 access anywhere"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "port 22 from home"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["95.147.237.10/32"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}


resource "aws_instance" "nodejs_instance" {
    ami = var.ami["app"]
    instance_type = "t2.micro"
    associate_public_ip_address = true
    key_name = var.keys["jared"]
    vpc_security_group_ids = [ aws_security_group.appSG.id ]
    tags = {
      "Name" = "eng74-jared-terraform-app"
    }
}
```

<br>

### What's next?
- Find a way to update the `DB_HOST` environment variable when creating the app instance so that it automatically connects to the newly-created database instance


---
**Used:**

1. [Variables in Terraform](https://upcloud.com/community/tutorials/terraform-variables/)