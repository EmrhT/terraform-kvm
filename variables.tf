variable "img_path" {
  description = "ubuntu 22.04 image local path"
  default     = "/opt/kvm_images/jammy-server-cloudimg-amd64.img"
}

variable "domain" {
  default = "example.com"
}

variable "interface" {
  type = string
  default = "ens3"
}

#load balancer
variable "lb_ips" {
  type = list
  default = ["192.168.122.11", "192.168.122.22"]
}

variable "lb_memory" {
  type  = string
  default = "512"
}

variable "lb_vcpu" {
  type = number
  default = 1
}

variable "lb_hostname" {
  type    = list(string)
  default = ["lb1", "lb2"]
}

#application server
variable "app_ips" {
  type = list
  default = ["192.168.122.44", "192.168.122.55"]
}

variable "app_memory" {
  type  = string
  default = "1024"
}

variable "app_vcpu" {
  type = number
  default = 1
}

variable "app_hostname" {
  type    = list(string)
  default = ["app1", "app2"]
}

#database servers
variable "db_ips" {
  type = list
  default = ["192.168.122.77", "192.168.122.88"]
}

variable "db_memory" {
  type  = string
  default = "2048"
}

variable "db_vcpu" {
  type = number
  default = 2
}

variable "db_hostname" {
  type    = list(string)
  default = ["db1", "db2"]
}