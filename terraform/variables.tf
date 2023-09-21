variable "proxmox_token_id" {
    type = string
}

variable "proxmox_token_secret" {
    type = string
}

variable "ssh_key" {
    default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMek8Cn3KNlEeHP2f9vZCbx/hzNc3xzJI9+2FM7Mbx5y mycroft@nee.mkz.me"
}

variable "proxmox_host" {
    default = "night-flight"
}

variable "template_name" {
    default = "ubuntu-basic-20230921"
}
