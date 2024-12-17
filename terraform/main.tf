terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc6"
    }
  }
}

provider "proxmox" {
  pm_api_url = "https://pve.turtok.duckdns.org/api2/json"
  pm_debug   = true
}

resource "proxmox_vm_qemu" "vms" {
  for_each = var.vms

  vmid             = each.value.vmid
  name             = each.value.name
  target_node      = "pve"
  agent            = 1
  cores            = each.value.cores
  memory           = each.value.memory
  boot             = "order=scsi0"
  clone            = each.value.template
  scsihw           = "virtio-scsi-single"
  vm_state         = "running"
  automatic_reboot = true

  # Cloud-Init configuration
  cicustom   = "vendor=local:snippets/qemu-guest-agent.yml" # /var/lib/vz/snippets/qemu-guest-agent.yml
  ciupgrade  = true
  nameserver = each.value.nameserver
  ipconfig0  = "ip=${each.value.ip}/24,gw=${each.value.gateway}"
  skip_ipv6  = true
  ciuser     = each.value.ciuser
  cipassword = each.value.cipassword
  sshkeys    = each.value.sshkeys

  # Most cloud-init images require a serial device for their display
  serial {
    id = 0
  }

  disks {
    scsi {
      scsi0 {
        # We have to specify the disk from our template, else Terraform will think it's not supposed to be there
        disk {
          storage = "local-lvm"
          # The size of the disk should be at least as big as the disk in the template. If it's smaller, the disk will be recreated
          size = each.value.disk_size
        }
      }
    }
    ide {
      # Some images require a cloud-init disk on the IDE controller, others on the SCSI or SATA controller
      ide1 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
  }

  network {
    id     = 0
    bridge = "vmbr0"
    model  = "virtio"
  }
}
