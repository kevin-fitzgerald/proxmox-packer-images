build {
  name = "images"
    
  source "proxmox-iso.common" {
    name = "baseline"

    node = var.proxmox_node
    
    vm_id = var.proxmox_template_vm_id
    template_name        = "ubuntu-server-baseline"
    template_description = "Ubuntu Server Baseline Image"
  }

  provisioner "ansible" {
    playbook_file    = "./ansible/baseline.yaml"
    user             = "root"
    roles_path       = "./ansible/roles"
    galaxy_file      = "./ansible/requirements.yaml"
  }
}
