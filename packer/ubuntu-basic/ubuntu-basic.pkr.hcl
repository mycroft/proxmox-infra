variable "proxmox_username" {
	type = string
    default = "${env("PROXMOX_USERNAME")}"

}

variable "proxmox_password" {
	type = string
    default = "${env("PROXMOX_PASSWORD")}"
}

variable "vm_name" {
    type    = string
    default = "ubuntu-basic-20230921"
}

source "proxmox-iso" "ubuntu-basic" {
    vm_name = "${var.vm_name}"

	proxmox_url = "https://10.0.0.7:8006/api2/json"
	username = "${var.proxmox_username}"
	password = "${var.proxmox_password}"
	insecure_skip_tls_verify = true

	node = "night-flight"

    iso_file = "local:iso/ubuntu-22.04.3-live-server-amd64.iso"
    unmount_iso = true
    iso_storage_pool = "local"

    disks {
        disk_size = "32G"
        storage_pool = "local-lvm"
    }

    cores = "1"
    memory = "2048"

    network_adapters {
        model = "virtio"
        bridge = "vmbr0"
        firewall = "false"
    }

    qemu_agent = true

    # VM Cloud-Init Settings
    cloud_init = false
    # cloud_init_storage_pool = "local-lvm"

    # PACKER Boot Commands
    boot_command = [
    	"c",
    	"linux /casper/vmlinuz --- autoinstall ds='nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/' ",
    	"<enter><wait>",
    	"initrd /casper/initrd<enter><wait>",
    	"boot<enter>"
    ]
    boot = "c"
    boot_wait = "5s"

    http_directory = "http" 

    ssh_username = "mycroft"
    ssh_agent_auth = true
    ssh_keypair_name = "id_ed25519"

    ssh_timeout = "20m"
}

build {
	name = "ubuntu-basic"
	sources = ["source.proxmox-iso.ubuntu-basic"]

    provisioner "shell" {
        inline = [
            "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
            "sudo rm /etc/ssh/ssh_host_*",
            "sudo truncate -s 0 /etc/machine-id",
            "sudo apt -y autoremove --purge",
            "sudo apt -y clean",
            "sudo apt -y autoclean",
            "sudo cloud-init clean",
            "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
            "sudo sync"
        ]
    }

    provisioner "file" {
        source = "files/99-pve.cfg"
        destination = "/tmp/99-pve.cfg"
    }

    provisioner "shell" {
        inline = [ "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg" ]
    }

    provisioner "shell" {
        inline = [
            "sudo apt-get install -y ca-certificates curl gnupg lsb-release",
            "sudo apt-get -y update"
        ]
    }
}
