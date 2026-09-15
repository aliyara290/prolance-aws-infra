terraform {
    backend "s3" {
      bucket = "my-terraform-state-bucket-290"
      key = "dev/terraform.state"
      region = "eu-west-3"
      use_lockfile = true
    }
}

