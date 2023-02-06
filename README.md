### Automation of Provisioning with Terraform on Libvirt/KVM
This repo provides a testbed where an on-prem KVM-based virtual environment is present and Terraform being utilised for automated provisioning.

## Prerequisites
1. A Linux computer (VM or physical) with the required KVM/libvirt components installed (kvmhost). --> https://linuxhint.com/install-kvm-ubuntu-22-04/
2. Terraform binaries installed (v1.3.7) --> https://developer.hashicorp.com/terraform/cli/install/apt
3. An intermediate level of domain (Terraform, KVM/libvirt) knowledge.

## Code
1. Remote state backend configured for more flexibility and collaboration.
2. libvirt provider is utilised as the main component. --> https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs
3. There are three types of VMs in main.tf; load balancers, application servers and database servers where all of their numbers and specs (CPU, memory, network config etc.) are dynamic and parameterized.
4. Each type of server has three libvirt resources; domain, volume and cloudinit_disk.
5. Variables come from variables.tf.
6. network_config.cfg and cloud_init.cfg are the files for cloudinit where former is for network config and latter for config such as user creation and access.
7. Resulting topology is somewhat as it is given below.

![image](https://user-images.githubusercontent.com/33878173/217013985-918ed885-224b-4dcf-973c-8a54f16d739a.png)

## Execution
1. "Terraform validate & init & plan & apply & destroy" lifecycle applies.
2. Beware that some changes in the config (such as CPU count) requires destroy&recreate after "terraform apply" whereas some can be handled in-place. Luckily, Terraform is smart enough to deal with it.
3. Within seconds, arbitrary number (bound with your resources of course) of VMs are provisioned, modified to your desired state or destroyed.

[Screencast.webm](https://user-images.githubusercontent.com/33878173/217064546-77e3cb4c-fe62-4161-9f6d-4dc8c94f72b9.webm)
