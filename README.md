# Terraform and AMI's

- This repository contains the notes made whilst learning Terraform
- It details iterations of previous code
- There are no folders that contain the nodejs app anymore; all the code is now present within an AMI we created using Packer 

<br>

## Contents

0. [Overview](https://github.com/jaredsparta/Terraform-1#Overview)
    1. [Quickstart](https://github.com/jaredsparta/Terraform-1#Quickstart)
1. [What is Terraform](https://github.com/jaredsparta/Terraform-1#What-is-Terraform)
2. [Why Terraform](https://github.com/jaredsparta/Terraform-1#Why-Terraform)
3. [Main Commands](https://github.com/jaredsparta/Terraform-1#Main-Commands-and-Overview)
4. [Explanations](https://github.com/jaredsparta/Terraform-1#Explanations)
    1. [EC2 instances](https://github.com/jaredsparta/Terraform-1#Terraform-to-create-an-EC2-instance)
    2. [Security groups](https://github.com/jaredsparta/Terraform-1#Terraform-to-create-Security-groups)
    3. [Variables](https://github.com/jaredsparta/Terraform-1#Variables-in-Terraform)
    4. [Connecting DB and APP](https://github.com/jaredsparta/Terraform-1#Connecting-the-database-and-app-instances-within-Terraform)
    5. [VPCs and more](https://github.com/jaredsparta/Terraform-1#VPCs-subnets-and-more-infrastructure)
    6. [Module explanation](https://github.com/jaredsparta/Terraform-1#Terraform-modules)
    7. [Modularising the code](https://github.com/jaredsparta/Terraform-1#Modularising-code)
5. [Links](https://github.com/jaredsparta/Terraform-1#Used)

<br>

## Overview
- `archive` details the previous iteration of the code
- `modules` contains the modules used in the code
- `main.tf` contains the code used to get the app running correctly
- `variables.tf` contains variables used in the the code, to make it more dynamic. You will need to input more variables as mentioned in section 4
- `template.tpl` details the bash script used to connect the app and database after they are created. This is used with the `templatefile` function and is run on the app instance


### Quickstart
1. Go to section 4 [here](https://github.com/jaredsparta/Terraform-1#Connecting-the-database-and-app-instances-within-Terraform) and add that block of code into `variables.tf`
    - If you are going to be putting anything on GitHub, then I suggest creating another `private-variables.tf` file, inserting that block of code in there and putting that file into `.gitignore`
2. Change the variables in `variables.tf` to what you desire
3. Ensure the AWS secret and access keys are in your environment variables (as Terraform looks there by default)
4. Go into `main.tf` and configure the names, instance types etc. to what you need
5. `$ terraform init` to load all the modules
6. `$ terraform validate` to check for syntax errors -- if there are any, you will have to fix them before moving on
7. `$ terraform apply` to create the infrastructure
8. `$ terraform destroy` to destroy the infrastructure

<br>

[Back to top](https://github.com/jaredsparta/Terraform-1#Contents)

## What is Terraform

![](images/diagram.jpg)

- Terraform is a tool for building, changing, and versioning infrastructure safely and efficiently. Terraform can manage existing and popular service providers as well as custom in-house solutions.
- The infrastructure Terraform can manage includes low-level components such as compute instances, storage, and networking, as well as high-level components such as DNS entries, SaaS features, etc.
- This information was found [here](https://www.terraform.io/intro/index.html)

<br>

[Back to top](https://github.com/jaredsparta/Terraform-1#Contents)


## Why Terraform

- It is agentless so there is no need to install any extra agents apart from Terraform itself
- It is declarative so all you need to do is declare what state you want the infrastructure and Terraform will do the rest for you
- It is cloud-independent, we can use Terraform for AWS, Azure, etc. 

<br>

[Back to top](https://github.com/jaredsparta/Terraform-1#Contents)

## Main Commands and Overview
- As can be seen when typing `terraform -help`, the main commands are:
    1. `init` - prepares working directory for the other commands
    2. `validate` - checks if the configuration file is valid
    3. `plan` - will show what will change in the infrastructure after applying
    4. `apply` - creates or updates infrastructure
    5. `destroy` - destroys previously-created infrastructure
    6. `refresh` - used to reconcile the state Terraform knows about (via its state file) with the real-world infrastructure

- There are other CLI commands you can use which can be seen using `terraform -help`

- `terraform.tfstate` and `terraform.tfstate.backup` contains the Terraform states. This is how Terraform keeps track of the relationship between your configuration files and the infrastructure it provisions

- `.terraform` is the directory that is created when you `terraform init`. It contains all the modules and plugins used to provision your infrastructure. These are specific to a certain instance of Terraform and not the actual infrastructure. This relates to the configuration files you have.

<br>

[Back to top](https://github.com/jaredsparta/Terraform-1#Contents)

## Explanations
- In the following, the AMI's used are already provisioned to run the app and the database (via Packer and Ansible)
- The following examples use variables named within a separate `.tf` file. These variables are found in `variables.tf`
    - I have omitted the AMI ID's as well as my own personal IP address. You would need to add these to that file for Terraform to work entirely. So add the following in that file:
    ```tf
    variable "personal" {
        type = map
        default = {
            "key" = "key-name"
            "ip" = "ip-address/32"
        }
    }

    variable "ami" {
        type = map
        default = {
            "app" = "ami-id"
            "db" = "ami-id"
        }
    }
    ```

<br>

[Back to top](https://github.com/jaredsparta/Terraform-1#Contents)

### Terraform to create an EC2 instance
- One can create EC2 instances using the resource `aws_instance`
- Documentation can be found [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)
- The following creates the app EC2 instance
```
resource "aws_instance" "nodejs_instance" {
    ami = var.ami["app"]
    instance_type = "t2.micro"
    associate_public_ip_address = true
    key_name = var.personal["key"]
    vpc_security_group_ids = [ aws_security_group.appSG.id ]
    tags = {
      "Name" = "eng74-jared-terraform-app"
    }
}
```

<br>

[Back to top](https://github.com/jaredsparta/Terraform-1#Contents)

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
        cidr_blocks = [ aws_security_group.appSG.id ]
    }

    ingress {
        description = "port 22 from home"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [ var.personal["ip"] ]
    }

    egress {
        description = "outbound with no restrictions"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
}
```

<br>

[Back to top](https://github.com/jaredsparta/Terraform-1#Contents)

### Variables in Terraform
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
    description = "the security group for the app via terraform"

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
        cidr_blocks = [ var.personal["ip"] ]
    }

    egress {
        description = "outbound with no restrictions"
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
    key_name = var.personal["key"]
    vpc_security_group_ids = [ aws_security_group.appSG.id ]
    tags = {
      "Name" = "eng74-jared-terraform-app"
    }
}
```

<br>

[Back to top](https://github.com/jaredsparta/Terraform-1#Contents)

### Connecting the database and app instances within Terraform
- AWS has a built-in provisioner that runs whenever an instance is created, we can use it to connect the database and app
- Once the database instance is created, we can reference it's private ip and use it to connect the two
- The code is written below:
```tf
resource "aws_instance" "nodejs_instance" {
    ami = var.ami["app"]
    instance_type = "t2.micro"
    associate_public_ip_address = true
    key_name = var.personal["key"]
    vpc_security_group_ids = [ aws_security_group.appSG.id ]
    user_data = <<-EOF
        #!/bin/bash
        echo "export DB_HOST=${db-ip}" >> /home/ubuntu/.bashrc
        export DB_HOST=${db-ip}
        cd /home/ubuntu/app
        pm2 kill
        pm2 start app.js --update-env
        pm2 restart app.js --update-env
        EOF
    tags = {
      "Name" = "eng74-jared-terraform-app"
    }
}
```

- Writing inline is good but if we wanted to create multiple ones, it would be a good idea to create a template file and just call it whilst passing the required variables to it
```tf
resource "aws_instance" "nodejs_instance" {
    ami = var.ami["app"]
    subnet_id = aws_subnet.public_subnet.id
    instance_type = var.instance_types["app"]
    associate_public_ip_address = true
    key_name = var.personal["key"]
    vpc_security_group_ids = [aws_security_group.appSG.id]
    user_data = templatefile("./template.tpl", { db-ip = aws_instance.mongodb_instance.private_ip })
    tags = {
      "Name" = "eng74-jared-terraform-app"
    }
}
```

- This is a cleaner version and we call a template which has this structure:
```tf
#!/bin/bash
echo "export DB_HOST=${db-ip}" >> /home/ubuntu/.bashrc
export DB_HOST=${db-ip}
cd /home/ubuntu/app
pm2 kill
pm2 start app.js --update-env
pm2 restart app.js --update-env
```

<br>

[Back to top](https://github.com/jaredsparta/Terraform-1#Contents)

### VPCs, subnets and more infrastructure
- We now want to create our own VPC alongside a private and public subnet. We also want to create the necessary infrastructure (route tables, network ACLs etc.)

- The code is split up among several files in `archive/terraform-files`. The resources used were:
    - `aws_vpc`
    - `aws_subnet`
    - `aws_internet_gateway`
    - `aws_route_table` and `aws_route_table_association`
    - `aws_network_acl`

- If one looks in `modules/vpc-etc/main.tf` they will see the entire network infrastructure in a single file

<br>

[Back to top](https://github.com/jaredsparta/Terraform-1#Contents)

### Terraform modules
- For more complex systems (not necessarily this one), configuration files would get increasingly harder to navigate and updating configuration files would get harder due to possible conflicts with other resources etc.
- Using Terraform modules will help with such problems. They:
    1. Organise configuration files
    2. Encapsulate configuration files
    3. Make config files re-usable
    4. Provide consistency and ensures best practices
    5. Help reduce errors

- What is a module?
    - They are basically just a set of configuration files in a single directory. A simple example of a module is:
    ```shell
    $ tree minimal-module/
    .
    ├── LICENSE
    ├── README.md
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ```
    - If you run terraform commands within this directory, you will not actually use the module but rather the configuration files

- How do we call a module?
    - When you run terraform commands, terraform will use the configuration files found in the current directory 
    - Calling modules is as simple as using them within the configuration files of the current directory
    - When you have a `module` block, terraform will load and process that module and place it within `.terraform` -- whenever you add a new module to the configuration files you will need to `terraform init` to ensure the module is loaded by terraform

- Best practices?
    - Look at the documentation [https://learn.hashicorp.com/tutorials/terraform/module](https://learn.hashicorp.com/tutorials/terraform/module)

- Ensure you remove `terraform.tfstate`, `terraform.tfstate.backup`, `.terraform` and `*.tfvars`. You do not want to distribute them as part of your module.

- Child modules will inherit the provider from the parent module, so you will need to remove any references to `provider`

- Brief overview:
    - Each module can have certain input variables, allowing more dynamic declarations. The names of the input variables can be found in the `variables.tf` file within a module
    - A module can output variables too. When modules are used in other configuration files, the parent module can reference the output of child modules. Such outputs can be found in the `outputs.tf` files within a module

<br>

[Back to top](https://github.com/jaredsparta/Terraform-1#Contents)

### Modularising code
- There is a `modules` folder that has a folder called `vpc-etc`. This folder contains a module that will create a VPC alongside public/private subnets, NACLs, route tables, etc.
    - The folder also contains modules to create an app and database

- To call a module inside a configuration file, use the `module` keyword like shown below:
    - Some modules require variables to be used properly, you will have to pass them values in this declaration
    - `vpc_stuff` is the identifier for this module

```tf
module "vpc_stuff" {
    source = "./modules/vpc-etc"

    app_security_group_name = "eng74.jared.SG.app.terraform"
    db_security_group_name = "eng74.jared.SG.db.terraform"
    vpc_name = "eng74-jared-terraform-vpc"
    public_subnet_name = "eng74-jared-terraform-public"
    private_subnet_name = "eng74-jared-terraform-private"
    igw_name = "eng74-jared-terraform-IGW"
    public_route_table_name = "eng74-jared-terraform-route-public"
    private_route_table_name = "eng74-jared-terraform-route-private"
    aws_key = var.personal["key"]
    vpc_cidr_block = var.cidr_blocks["vpc"]
    public_subnet_cidr_block = var.cidr_blocks["public_subnet"]
    private_subnet_cidr_block = var.cidr_blocks["private_subnet"]
    personal_ip = var.personal["ip"]
}
```

- Modules can also output variables for parent modules to use. These are defined in `outputs.tf`. To call outputs from child modules, use the `module.<identifier>.<name>`

- For example, suppose we have the following outputs file:
```tf
# The outputs from the module

# SUBNET IDs
output "private_subnet_id" {
    value = aws_subnet.private_subnet.id
}

output "public_subnet_id" {
    value = aws_subnet.public_subnet.id
}

# SECURITY GROUP IDs
output "private_security_group_id" {
    value = aws_security_group.dbSG.id
}

output "public_security_group_id" {
    value = aws_security_group.appSG.id
}
```

- If within the parent module we give the child module the identifier `vpc_stuff`, one would reference the `private_subnet_id` output from the child module with `module.vpc_stuff.private_subnet_id`

<br>

[Back to top](https://github.com/jaredsparta/Terraform-1#Contents)

### What's next?

- Create a Bastion server so the database is more secure

<br>

---
## Used

1. [Variables in Terraform](https://upcloud.com/community/tutorials/terraform-variables/)
2. [Outputs in main.tf vs. outputs.tf](https://jmarhee.medium.com/outputs-with-terraform-modules-ec0ce38ea1ad)
3. [Info on Terraform modules](https://blog.gruntwork.io/how-to-create-reusable-infrastructure-with-terraform-modules-25526d65f73d#ff91)
4. [More info on modules](https://learn.hashicorp.com/tutorials/terraform/module)

[Back to top](https://github.com/jaredsparta/Terraform-1#Contents)
