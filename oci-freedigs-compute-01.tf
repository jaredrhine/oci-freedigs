resource oci_core_instance freedigs_compute_01 {
  compartment_id = var.compartment_ocid
  availability_domain = var.availability_domain_map[var.oci_region]

  metadata = {
    ssh_authorized_keys = var.compute_ssh_public_key
    user_data = base64encode(templatefile("cloudinit-userdata.tpl.yaml", {
      compute_username = var.compute_username,
      compute_ssh_public_key = var.compute_ssh_public_key,
      tailscale_auth_key = var.tailscale_auth_key,
    }))
  }

  shape = var.compute_shape
  shape_config {
    ocpus = var.compute_cores
    memory_in_gbs = var.compute_ram_gb
  }

  source_details {
    source_type = "image"
    source_id = var.compute_image_ocid_map[var.oci_region]
    boot_volume_size_in_gbs = var.compute_disk_gb
  }

  create_vnic_details {
    hostname_label = var.compute_hostname
    assign_public_ip = "true"
    assign_private_dns_record = "true"
    subnet_id = oci_core_subnet.freedigs_subnet_main.id
  }

  display_name = var.compute_hostname

  instance_options {
    are_legacy_imds_endpoints_disabled = "true"
  }
  is_pv_encryption_in_transit_enabled = "true"

  agent_config {
    plugins_config {
      desired_state = "DISABLED"
      name = "Vulnerability Scanning"
    }
    plugins_config {
      desired_state = "ENABLED"
      name = "Compute Instance Monitoring"
    }
  }
}
