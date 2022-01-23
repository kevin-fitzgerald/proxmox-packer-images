variable "proxmox_username" {
    type        = string
    description = "proxmox api username or token identifier"
}

variable "proxmox_token" {
    type        = string
    description = "proxmox api token secret value"
    sensitive   = true
}

variable "proxmox_host" {
    type        = string
    description = "hostname or ip of the proxmox server"
}

variable "proxmox_port" {
    type        = number
    description = "tcp port proxmox is listening on"
    default     = 8006
}

variable "proxmox_node" {
    type        = string
    description = "name of the proxmox node to store the image on"
    default     = "pve"
}

variable "proxmox_image_storage_pool" {
    type        = string
    description = "name of the storage pool used for storing vm images"
}

variable "proxmox_image_storage_pool_type" {
  type        = string
  description = "type of storage pool used for storing vm images"
}

variable "proxmox_cloud_init_storage_pool" {
  type        = string
  description = "name of the storage pool used for storing cloud-init cds"
}

variable "proxmox_iso_storage_pool" {
  type        = string
  description = "name of the storage pool used for storing iso images"
}

variable "proxmox_provisioning_bridge" {
  type        = string
  description = "Name of the linux bridge associated with the provisioning VLAN."
  default     = "vmbr0"
}

variable "proxmox_provisioning_vlan" {
  type        = number
  description = "vlan tag of the vm provisioning network"
}

variable "proxmox_template_vm_id" {
  type        = number
  description = "VM ID assigned to the created template VM."
  default     = 200
}

variable "packer_host_http_port" {
  type        = number
  description = "TCP port on the packer host which will run an http server for preseeding"
  default     = 8080
}

variable "packer_host_ip" {
  type        = string
  description = "ip of the packer host, grabbing the subiquity install config from a local http server"
}

variable "ubuntu_server_version" {
  type        = string
  description = "Ubuntu Server version, including minor version."
  default     = "20.04.3"
}

variable "ubuntu_server_checksum" {
  type        = string
  description = "SHA256 Checksum for the specified Ubuntu Server version ISO."
  default     = "f8e3086f3cea0fb3fefb29937ab5ed9d19e767079633960ccb50e76153effc98"
}

variable "ubuntu_user_name" {
  type        = string
  description = "Name of the linux user to create."

  validation {
    condition     = var.ubuntu_user_name != "root"
    error_message = "Ubuntu user name must not be 'root'."
  }
}

variable "ubuntu_user_password" {
  type        = string
  description = "Password for the primary linux user.  Required for sudo."
  sensitive   = true
}

variable "ubuntu_user_ssh_public_key" {
  type        = string
  description = "Content of the ssh public key or URL of a GitHub public key, assigned to the primary linux user."
}
