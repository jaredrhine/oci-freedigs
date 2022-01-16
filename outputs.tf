output "compute_01_public_ip" {
  description = "The public IP address assigned to the compute-01 instance"
  value = oci_core_instance.freedigs_compute_01.public_ip
}
