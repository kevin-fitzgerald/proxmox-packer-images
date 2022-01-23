# Proxmox Guest Images

## Description
This repo contains Packer builds and Ansible playbooks used for automatically creating cloud-init ready VM templates in Proxmox virtual environment.

Currently, all builds and Ansible roles expect the target OS to be Ubuntu Server.  I may add support for additional OS's in the future.

## Contents
* [Requirements](#requirements)
  * [Software](#software)
  * [Proxmox Configuration](#proxmox-configuration)
  * [Physical Network](#physical-network)
* [Usage](#usage)
* [Variables](#variables)
* [About 'keys'](#about-keys)
* [Considerations for Windows Users](#windows)
* [Disclaimer](#disclaimer)

## Requirements <a name=requirements />
### Software <a name=software />
* [Packer](https://learn.hashicorp.com/tutorials/packer/get-started-install-cli)
* [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-and-upgrading-ansible-with-pip)
* [Proxmox Virtual Environment](https://www.proxmox.com/en/proxmox-ve)
### Proxmox Configuration <a name=proxmox-configuration />
* Proxmox API Token with the following permissions:
  * Datastore.*
  * VM.Allocate
  * VM.Audit
  * VM.Clone
  * VM.Config.*
  * VM.Console
  * VM.Monitor
  * VM.PowerMgmt
* Datastores configured that can store Disk images, Snippets, and ISO images.
* A Linux Bridge with an attached Linux VLAN for provisioning.
* A trusted certificate (e.g. Lets Encrypt) in use for the Proxmox web server.
### Physical Network <a name=physical-network />
Packer spins up an HTTP server on the local machine to distribute preseed files to the template server for automatic provisioning. As such, your network must allow the template server to reach your local machine over HTTP on the configured port.

## Usage <a name=usage />
1. Create a *.pkrvars.hcl file containing the variable values (see below) for your environment.  See 'fitztech.pkrvars.hcl' as an example of what I use.

3. Ensure your configuration is valid
```bash
packer validate -var-file=<your-file-name>.pkrvars.hcl .
```
4. Execute the build
```bash
packer build -var-file=<your-file-name>.pkrvars.hcl .
```
5. Once the build is complete, you can edit the Cloud Init section of the template in the Proxmox UI with default values for User, Password, SSH, and DNS.  The settings will be inherited by clones.
6. Clone the template.
7. Customize the Cloud Init IP address, VLAN ID of the network interface, and disk size of the clone, then start the VM.

## Variables <a name=variables />
| Name | Description | Default |
| ---- | ------------|---------|
| **proxmox_username** | Proxmox api username or token identifier. |  |  
| **proxmox_token** | Proxmox api token secret value. Provide this value using the PKR_VAR_proxmox_token environment variable. |  |
| **proxmox_host** | Hostname or ip of the proxmox server. |  |
| **proxmox_port** | Tcp port proxmox is listening on. | 8006 |
| **proxmox_node** | Name of the proxmox node to store the image on. | "pve" |
| **proxmox_image_storage_pool** | Name of the storage pool used for storing vm images. |  |
| **proxmox_image_storage_pool_type** | Type of storage pool used for storing vm images. |  |
| **proxmox_cloud_init_storage_pool** | Name of the storage pool used for storing cloud-init cds. |  |
| **proxmox_iso_storage_pool** | Name of the storage pool used for storing iso images. |  |
| **proxmox_provisioning_bridge** | Name of the linux bridge associated with the provisioning VLAN | "vmbr0" |
| **proxmox_provisioning_vlan** | Vlan tag of the vm provisioning network. |  |
| **proxmox_template_vm_id** | VM ID assigned to the created template VM. | 200 |
| **packer_host_http_port** | TCP port on the packer host which will run an http server for preseeding. | 8080 |
| **packer_host_ip** | IP of the packer host, grabbing the subiquity install config from a local http server. |  |
| **ubuntu_server_version** | Ubuntu Server version, including minor version. | "20.04.3" |
| **ubuntu_server_checksum** | SHA256 Checksum for the specified Ubuntu Server version ISO. | f8e3086f3cea0fb3fefb29937ab5ed9d19e767079633960ccb50e76153effc98 |

## About 'keys' <a name=about-keys />
For convenience, I've seeded this project with an SSH private and public key used by the root user to connect and execute Ansible playbooks during provisioning. Each of th images applies the devsec.hardening.ssh_hardening ansible role, which disables all forms of root SSH authentication.  Additionally, the final step of the 'sysprep' role removes the corresponding SSH public key from the root users authorized keys list.  Still, it is conceivable that while provisioning is running someone could grab the private key from this repo and SSH into the machine as root.  For my use case this risk is acceptable, but it may not be for yours.

## Considerations for Windows Users <a name=windows />
While Packer is available as a Windows executable, Ansible does not currently have a native Windows build available.  My solution to this problem is to use Windows Subsytem for Linux (WSL), specifically with the Ubuntu distro.

Using WSL introduces a few complications:
1. Both Packer and Ansible should be installed within WSL, rather than on Windows.
2. This repo can be either on the Windows filesystem or the WSL filesystem, but you will get better perfomance using a native WSL path, e.g. /home/kevin/...
3. The Packer HTTP server used for serving preseed files is bound to the WSL IP, rather than the Windows host IP.  To get around this you can port forward your Packer HTTP port from your host IP to WSL.  See below for an example PowerShell function that is a wrapper around netsh to accomplish the port forward.  The function needs to be run from an elevated PowerShell prompt.  Make sure your Windows firewall allows your Packer HTTP port through the host IP as well.
```PowerShell
# Forward a host port to WSL
function New-WSLPortForward {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $Port,

        [Parameter()]
        [string]
        $WslIp = $(wsl hostname -I).trim()
    )

    netsh interface portproxy add v4tov4 listenport=$Port connectport=$Port connectaddress=$WslIp
}
```

## Disclaimer <a name=disclaimer />
The code in this repo is what I actually use to manage my infrastructure, and is not intended to funtion as a general use tool.  I've made the code public in case it is helpfully to anyone.
