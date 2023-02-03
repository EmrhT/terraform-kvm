terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.7.1"
    }
  }

  backend "s3" {
    bucket   = "emrah-aws-terraform-state-bucket"
    key      = "tf-kvm/terraform.tfstate"
    region   = "eu-central-1"
  }

}

provider "libvirt" {
  uri = "qemu+ssh://root@kvmhost.example.com/system"    
  # Configuration options
}