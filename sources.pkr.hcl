source "proxmox-iso" "common" {
  proxmox_url = "https://${var.proxmox_host}:${var.proxmox_port}/api2/json"
  
  username = var.proxmox_username
  token    = var.proxmox_token

  ssh_username           = "root"
  ssh_private_key_file   = "./keys/root"
  ssh_timeout            = "15m"
  ssh_handshake_attempts = "30"
  qemu_agent             = true

  vm_name = "packer-temp-vm"
  
  iso_url          = "https://releases.ubuntu.com/${var.ubuntu_server_version}/ubuntu-${var.ubuntu_server_version}-live-server-amd64.iso"
  iso_storage_pool = var.proxmox_iso_storage_pool
  iso_checksum     = var.ubuntu_server_checksum
  unmount_iso      = true
  os               = "l26"

  scsi_controller = "virtio-scsi-single"

  cores    = "2"
  sockets  = "1"
  cpu_type = "host"

  memory = "4096"

  network_adapters {
    bridge   = var.proxmox_provisioning_bridge
    model    = "virtio"
    vlan_tag = var.proxmox_provisioning_vlan
  }

  disks {
    disk_size         = "20G"
    format            = "raw"
    storage_pool      = var.proxmox_image_storage_pool
    storage_pool_type = var.proxmox_image_storage_pool_type
    type              = "scsi"
  }

  vga {
    type = "std"
  }

  cloud_init              = true
  cloud_init_storage_pool = var.proxmox_cloud_init_storage_pool

  http_directory = "subiquity/"
  http_port_max  = var.packer_host_http_port
  http_port_min  = var.packer_host_http_port

  boot_wait    = "3s"
  boot_command = [
    "<enter><wait><enter><wait>",
    "<f6><wait>",
    "<esc><wait>",
    " autoinstall ds=nocloud-net;s=http://${var.packer_host_ip}:{{ .HTTPPort }}/ <wait>",
    "<enter><wait>"
  ]
}
