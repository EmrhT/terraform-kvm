variable "libvirt_disk_path" {
  description = "path for libvirt pool"
  default     = "/opt/kvm/pool1"
}

variable "ubuntu_18_img_url" {
  description = "ubuntu 18.04 image"
  default     = "https://cloud-images.ubuntu.com/releases/jammy/release/ubuntu-22.04-server-cloudimg-amd64.img"
}

variable "vm_hostname" {
  description = "vm hostname"
  default     = "terraform-kvm-ansible"
}

variable "ssh_username" {
  description = "the ssh user to use"
  default     = "ubuntu"
}

variable "ssh_private_key" {
  description = "the private key to use"
  default     = "~/.ssh/id_rsa"
}