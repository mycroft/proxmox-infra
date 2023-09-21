resource "proxmox_vm_qemu" "kubernetes_server" {
  count       = 4
  name        = "kube-vm-${count.index + 1}"
  desc        = "Kubernetes node"
  target_node = var.proxmox_host
  clone       = var.template_name

  agent       = 1
  os_type     = "cloud-init"
  cores       = 2
  sockets     = 1
  cpu         = "host"
  memory      = 8192
  scsihw      = "virtio-scsi-pci"
  bootdisk    = "scsi0"
  qemu_os     = "l26"

  cloudinit_cdrom_storage = "local-lvm"

  disk {
    size     = "32G"
    type     = "scsi"
    storage  = "local-lvm"
  }

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  ipconfig0 = "ip=10.2.1.2${count.index + 1}/8,gw=10.0.0.1"

  lifecycle {
    ignore_changes = [
      network,
    ]
  }

  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
}
