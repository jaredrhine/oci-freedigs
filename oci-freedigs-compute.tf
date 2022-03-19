resource oci_core_instance freedigs_compute {
  for_each = var.compute_hosts

  compartment_id = var.compartment_ocid
  availability_domain = var.availability_domain_map[var.oci_region]

  metadata = {
    ssh_authorized_keys = var.compute_ssh_public_key
    user_data = "${data.template_cloudinit_config.multipart.rendered}"
  }

  shape = var.compute_shapes[each.value.arch]
  shape_config {
    ocpus = each.value.cores
    memory_in_gbs = each.value.ram_gb
  }

  source_details {
    source_type = "image"
    source_id = var.compute_image_ocid_map["${var.oci_region}.${each.value.arch}.${var.compute_os_label}"]
    boot_volume_size_in_gbs = each.value.disk_gb
  }

  create_vnic_details {
    hostname_label = each.value.hostname
    assign_public_ip = "true"
    assign_private_dns_record = "true"
    subnet_id = oci_core_subnet.freedigs_subnet_main.id
    nsg_ids = [oci_core_network_security_group.freedigs_security_group.id]
  }

  display_name = each.value.hostname

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

data "template_file" "cloudconfig" {
  template = "${file("${path.module}/cloudinit-config.tpl.yaml")}"
  vars = {
    admin_email = var.admin_email
    aws_access_key_id = var.aws_access_key_id,
    aws_secret_access_key = var.aws_secret_access_key,
    compute_ssh_public_key = var.compute_ssh_public_key,
    compute_ssh_public_key_backup = var.compute_ssh_public_key_backup,
    compute_username = var.compute_username,
    tailscale_auth_key = var.tailscale_auth_key,
  }
}

data "template_file" "boothook" {
  template = "${file("${path.module}/cloudinit-boothook.tpl.sh")}"
}

data "template_file" "script" {
  template = "${file("${path.module}/cloudinit-script.tpl.sh")}"
}

data "template_cloudinit_config" "multipart" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-boothook"
    content = "${data.template_file.boothook.rendered}"
  }

  part {
    content_type = "text/cloud-config"
    content = "${data.template_file.cloudconfig.rendered}"
  }

  part {
    content_type = "text/x-shellscript"
    content = "${data.template_file.script.rendered}"
  }

  part {
    content_type = "text/x-include-url"
    content = var.cloudinit_script_url
  }
}
