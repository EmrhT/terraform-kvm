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


# Load Balancers
resource "libvirt_cloudinit_disk" "lb_commoninit" {
  count = length(var.lb_hostname)
  name = "${var.lb_hostname[count.index]}-commoninit.iso"
  user_data = templatefile("${path.module}/cloud_init.cfg", {
    hostname = var.lb_hostname[count.index]
    fqdn   = "${var.lb_hostname[count.index]}.${var.domain}"
  })
  network_config =   templatefile("${path.module}/network_config.cfg", {
     interface = var.interface
     ip_addr   = var.lb_ips[count.index]
  })
}

resource "libvirt_volume" "lb_ubuntu2204-qcow2" {
  count = length(var.lb_hostname)
  name = "ubuntu2204-qcow2.${var.lb_hostname[count.index]}"
  pool = "default"
  source = var.img_path
  format = "qcow2"
}

resource "libvirt_domain" "load_balancer" {
  count = length(var.lb_hostname)
  name = "${var.lb_hostname[count.index]}"
  memory = var.lb_memory
  vcpu   = var.lb_vcpu
  qemu_agent  = "true"
  
  network_interface {
    network_name = "default"
    addresses    = [var.lb_ips[count.index]]
  }

  disk {
    volume_id = element(libvirt_volume.lb_ubuntu2204-qcow2.*.id, count.index)
  }

  cloudinit = libvirt_cloudinit_disk.lb_commoninit[count.index].id

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


# application servers
resource "libvirt_cloudinit_disk" "app_commoninit" {
  count = length(var.app_hostname)
  name = "${var.app_hostname[count.index]}-commoninit.iso"
  user_data = templatefile("${path.module}/cloud_init.cfg", {
    hostname = var.app_hostname[count.index]
    fqdn   = "${var.app_hostname[count.index]}.${var.domain}"
  })
  network_config =   templatefile("${path.module}/network_config.cfg", {
    interface = var.interface
    ip_addr   = var.app_ips[count.index]
  })
}

resource "libvirt_volume" "app_ubuntu2204-qcow2" {
  count = length(var.app_hostname)
  name = "ubuntu2204-qcow2.${var.app_hostname[count.index]}"
  pool = "default"
  source = var.img_path
  format = "qcow2"
}

resource "libvirt_domain" "application_server" {
  count = length(var.app_hostname)
  name = "${var.app_hostname[count.index]}"
  memory = var.app_memory
  vcpu   = var.app_vcpu
  qemu_agent  = "true"
  
  network_interface {
    network_name = "default"
    addresses    = [var.app_ips[count.index]]
  }

  disk {
    volume_id = element(libvirt_volume.app_ubuntu2204-qcow2.*.id, count.index)
  }

  cloudinit = libvirt_cloudinit_disk.app_commoninit[count.index].id

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


# database servers
resource "libvirt_cloudinit_disk" "db_commoninit" {
  count = length(var.db_hostname)
  name = "${var.db_hostname[count.index]}-commoninit.iso"
  user_data = templatefile("${path.module}/cloud_init.cfg", {
    hostname = var.db_hostname[count.index]
    fqdn   = "${var.db_hostname[count.index]}.${var.domain}"
  })
  network_config =   templatefile("${path.module}/network_config.cfg", {
     interface = var.interface
     ip_addr   = var.db_ips[count.index]
  })
}

resource "libvirt_volume" "db_ubuntu2204-qcow2" {
  count = length(var.db_hostname)
  name = "ubuntu2204-qcow2.${var.db_hostname[count.index]}"
  pool = "default"
  source = var.img_path
  format = "qcow2"
}

resource "libvirt_domain" "database_server" {
  count = length(var.db_hostname)
  name = "${var.db_hostname[count.index]}"
  memory = var.db_memory
  vcpu   = var.db_vcpu
  qemu_agent  = "true"
  
  network_interface {
    network_name = "default"
    addresses    = [var.db_ips[count.index]]
  }

  disk {
    volume_id = element(libvirt_volume.db_ubuntu2204-qcow2.*.id, count.index)
  }

  cloudinit = libvirt_cloudinit_disk.db_commoninit[count.index].id

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


output "lb_ip" {
  value = libvirt_domain.load_balancer.*.network_interface.0.addresses
}

output "app_ip" {
  value = libvirt_domain.application_server.*.network_interface.0.addresses
}

output "db_ip" {
  value = libvirt_domain.database_server.*.network_interface.0.addresses
}