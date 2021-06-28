provider "vsphere" {
  user           = "${var.vsphere_user}"
  password       = "${var.vsphere_password}"
  vsphere_server = "10.31.50.52"
  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "${var.vsphere_datacenter}"
}

data "vsphere_datacenter" "temp" {
  name = "${var.vsphere_datacenter_temp}"
}

data "vsphere_datastore" "datastore" {
  name          = "datastore-46"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

  data "vsphere_resource_pool" "pool" {
  name          = "Eng_Prod_Pool"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
  name          = "VM Network"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "template" {
  name          = "${var.vmtemp}"
  datacenter_id = "${data.vsphere_datacenter.temp.id}"
}

resource "vsphere_virtual_machine" "vm" {
  name             = "Ansible-Hv1"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"
  num_cpus = "${var.vm_cpu}"
  memory   = "${var.vm_ram}"
  guest_id = "${data.vsphere_virtual_machine.template.guest_id}"
  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"

  network_interface {
    network_id   = "${data.vsphere_network.network.id}"
    adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }

  disk {
    label            = "disk0"
    size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"
    
      

    customize {
      timeout = 50
      linux_options {
        host_name = "Ansible-Hv"
        domain    = "ansible.simpsons.qa"
      }
      network_interface {}
    }
  }
}

output "my_ip_address" {
 value = "${vsphere_virtual_machine.vm.default_ip_address}"
}