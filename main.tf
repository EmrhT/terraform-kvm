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
  uri = "qemu+ssh://root@kvmhost.example.com:53330/system"    
}

resource "libvirt_volume" "centos7-qcow2" {
  name = "centos7.qcow2"
  pool = "default" # List storage pools using virsh pool-list
  #source = "https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2"
  source = "/opt/CentOS-7-x86_64-GenericCloud.qcow2"
  format = "qcow2"
}

# Define KVM domain to create
resource "libvirt_domain" "centos7" {
  name   = "centos7"
  memory = "2048"
  vcpu   = 2
  qemu_agent  = "true"
  
  network_interface {
    network_name = "default" # List networks with virsh net-list
  }

  disk {
    volume_id = "${libvirt_volume.centos7-qcow2.id}"
  }

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
output "ip" {
  value = "${libvirt_domain.centos7.network_interface.0.addresses.0}"
}