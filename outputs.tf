output "compute_public_ip" {
  description = "The public IP address assigned to the compute instances"
  value = {
    for k, host in oci_core_instance.freedigs_compute : k => host.public_ip
  }
}
