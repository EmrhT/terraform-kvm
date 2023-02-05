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

}

data "template_file" "user_data" {
  count = length(var.hostname)
  template = file("${path.module}/cloud_init.cfg")
  vars = {
    hostname = element(var.hostname, count.index)
    fqdn = "${var.hostname[count.index]}.${var.domain}"
  }
}

resource "random_pet" "this" {
  length = 2
}

resource "libvirt_cloudinit_disk" "commoninit" {
  count = length(var.hostname)
  name = "${var.hostname[count.index]}-commoninit.iso"
  user_data = data.template_file.user_data[count.index].rendered
}

resource "libvirt_volume" "ubuntu2204-qcow2" {
  count = length(var.hostname)
  name = "ubuntu2204-qcow2.${var.hostname[count.index]}"
  pool = "default"
  source = var.img_path
  format = "qcow2"
}

# Define KVM domain to create
resource "libvirt_domain" "ubuntu2204" {
  count = length(var.hostname)
  name = "${var.hostname[count.index]}"
  memory = "2048"
  vcpu   = 2
  qemu_agent  = "true"
  
  network_interface {
    network_name = "default"
    addresses    = [var.ips[count.index]]
  }

  disk {
    volume_id = element(libvirt_volume.ubuntu2204-qcow2.*.id, count.index)
  }

  cloudinit = libvirt_cloudinit_disk.commoninit[count.index].id

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

output "ip" {
  value = libvirt_domain.ubuntu2204.*.network_interface.0.addresses
}