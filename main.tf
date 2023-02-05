terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.7.1"
    }
    template = {
      source = "hashicorp/template"
      version = "2.2.0"
    }
  }

  backend "s3" {
    bucket   = "emrah-aws-terraform-state-bucket"
    key      = "tf-kvm/terraform.tfstate"
    region   = "eu-central-1"
  }

}

provider "libvirt" {
  uri = "qemu+ssh://emrah@kvmhost.example.com:53330/system"    
}

provider "template" {
  # Configuration options
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
}

resource "random_pet" "this" {
  length = 2
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name      = "commoninit.iso"
  user_data = data.template_file.user_data.rendered
}

resource "libvirt_volume" "ubuntu2204-qcow2" {
  name = var.volume_name
  pool = "default" # List storage pools using virsh pool-list
  #source = "https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2"
  source = "/opt/kvm_images/jammy-server-cloudimg-amd64.img"
  format = "qcow2"
}

# Define KVM domain to create
resource "libvirt_domain" "ubuntu2204" {
  name = var.name
  memory = "2048"
  vcpu   = 2
  qemu_agent  = "true"
  
  network_interface {
    network_name = "default" # List networks with virsh net-list
  }

  disk {
    volume_id = "${libvirt_volume.ubuntu2204-qcow2.id}"
  }

  cloudinit = "${libvirt_cloudinit_disk.commoninit.id}"

  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }
}

# Output Server IP
# output "ip" {
#   value = "${libvirt_domain.centos7.network_interface.0.addresses.0}"
# }