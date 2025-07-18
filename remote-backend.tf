terraform {
  required_version = ">= 1.11.0"

  backend "s3" {
    bucket       = "resume-remote-backend"
    key          = "terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
