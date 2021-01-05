# Which cloud provider are we using? Our AMI's are on AWS
# The AMI's are region-specific so we also need to specify it
provider "aws" {
    region = "eu-west-1"
}