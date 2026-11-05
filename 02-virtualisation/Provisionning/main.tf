terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.50.0"
    }
  }
}

provider "proxmox" {
  endpoint = "https://10.0.10.10:8006/api2/json" # IP de votre hyperviseur Proxmox
  username = "root@pam!terraform"
  password = "VotreMotDePasseTerraform"
  insecure = true
}

resource "proxmox_virtual_environment_vm" "dhcp_server" {
  name      = "dhcp01"
  node_name = "pve01" # Nom de votre nœud Proxmox

  clone {
    vm_id     = 900 # ID de votre template cloud-init (ex: Debian 12 ou Rocky 9)
    full      = true
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 2048
  }

  network_device {
    bridge = "vmbr0"
    vlan_id = 50 # VLAN 50 pour les clients / réseaux locaux
  }

  initialization {
    ip_config {
      ipv4 {
        address = "10.0.50.254/24" # Passerelle ou IP fixe du serveur DHCP
        gateway = "10.0.50.1"
      }
    }
    user_data_file_id = proxmox_virtual_environment_file.cloud_init.id
  }
}