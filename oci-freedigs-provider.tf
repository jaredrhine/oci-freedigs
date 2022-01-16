provider oci {
  region = var.oci_region
  tenancy_ocid = var.tenancy_ocid
  user_ocid = var.user_ocid
  private_key_path = var.signing_key_private_path
  fingerprint = var.signing_key_fingerprint
}
