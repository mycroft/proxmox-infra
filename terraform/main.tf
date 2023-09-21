resource "proxmox_vm_qemu" "test_server" {
  count       = 0
  name        = "test-vm-${count.index + 1}"
  target_node = var.proxmox_host
  clone       = var.template_name

  agent       = 1
  os_type     = "cloud-init"
  cores       = 2
  sockets     = 1
  cpu         = "host"
  memory      = 2048
  scsihw      = "virtio-scsi-pci"
  bootdisk    = "scsi0"

  disk {
    slot     = 0
    size     = "32G"
    type     = "scsi"
    storage  = "local-lvm"
    iothread = 0
  }

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  ipconfig0 = "ip=10.2.1.1${count.index + 1}/24,gw=10.0.0.1"

  lifecycle {
    ignore_changes = [
      network,
    ]
  }

  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
}
