# proxmox-infra

## Packer

Build the required `ubuntu-basic` VM image/template to be used to start other VMs with `terraform`.

### Initial setup

It requires a `packer@pve` user in Proxmox. To create it:

```sh
$ pveum useradd packer@pve

$ pveum passwd packer@pve
Enter new password: ************
Retype new password: ************

$ pveum roleadd Packer -privs "VM.Config.Disk VM.Config.CPU VM.Config.Memory Datastore.AllocateSpace Sys.Modify VM.Config.Options VM.Allocate VM.Audit VM.Console VM.Config.CDROM VM.Config.Network VM.PowerMgmt VM.Config.HWType VM.Monitor SDN.Use VM.Config.Cloudinit"

$ pveum aclmod / -user packer@pve -role Packer
```

### Running

```sh
$ set -x PROXMOX_USERNAME packer@pve
$ set -x PROXMOX_PASSWORD (pass Mkz/night-flight/packer@pve)

$ packer init -upgrade plugins.pkr.hcl

$ packer validate ubuntu-basic.pkr.hcl
The configuration is valid.

$ packer build ubuntu-basic.pkr.hcl
[...snip...]
```

Source: https://github.com/hashicorp/packer-plugin-proxmox


## Terraform

Install & run VMs in proxmox.

### Initial setup

```sh
$ pveum role add TerraformProv -privs "Datastore.AllocateSpace Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt"

$ pveum user add terraform-prov@pve --password <password>

$ pveum aclmod / -user terraform-prov@pve -role TerraformProv
```

### Running

```sh
$ set -x TF_VAR_proxmox_url "https://10.0.0.7:8006/api2/json"
$ set -x TF_VAR_proxmox_token_id "terraform@pve!terraform"
$ set -x TF_VAR_proxmox_token_secret (pass Mkz/night-flight/terraform@pve)

$ terraform init
$ terrafrom validate
$ terraform plan
[...snip...]

$ terraform apply
[...snip...]
```

Don't forget to commit `terraform.tfstate` if change occurs.
