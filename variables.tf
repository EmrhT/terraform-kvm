variable "img_path" {
  description = "ubuntu 22.04 image local path"
  default     = "/opt/kvm_images/jammy-server-cloudimg-amd64.img"
}

variable "domain_name" {
  default = "ubuntu2204"
}

variable "volume_name" {
  default = "ubuntu2204_vol"
}

variable "hostname" {
  type    = list(string)
  default = ["lb1", "lb2", "app1"]
}

variable "domain" {
  default = "example.com"
}

variable "ips" {
  type = list
  default = ["192.168.122.11", "192.168.122.22", "192.168.122.33"]
}