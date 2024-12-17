variable "vms" {
  description = "List of VMs with their configuration"
  type = map(object({
    name       = string
    vmid       = number
    # hardware
    memory     = optional(number, 2048)
    disk_size  = optional(string, "32G")
    cores      = optional(number, 1)

    # cloudinit
    ciuser     = optional(string, "debian")
    cipassword = optional(string, "debian")
    sshkeys    = optional(string, "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDMawTwHuD3JBdN0OJ0bCDeKxCtD62/MtXCIBkchlBCo ljurk@abra")
    template   = optional(string, "debian12-cloudinit-tf")
    # networking
    ip         = string
    gateway    = optional(string, "192.168.0.1")
    nameserver = optional(string, "1.1.1.1 8.8.8.8")
  }))

  default = {
    truenas = {
      name      = "truenas"
      ip        = "192.168.0.40"
      memory    = 4096
      cores     = 2
      vmid      = 301
    }
    homeassistant = {
      name      = "homeassistant"
      ip        = "192.168.0.30"
      memory    = 4096
      vmid      = 302
      cores     = 2
    }
    tailscale = {
      name      = "tailscale"
      ip        = "192.168.0.5"
      vmid      = 303
    }
    prometheus = {
      name      = "prometheus"
      ip        = "192.168.0.31"
      vmid      = 304
    }
    grafana = {
      name      = "grafana"
      ip        = "192.168.0.32"
      vmid      = 305
    }
    crafty = {
      name      = "crafty"
      ip        = "192.168.0.50"
      vmid      = 306
      memory    = 8192
      cores     = 4
    }
  }
}
