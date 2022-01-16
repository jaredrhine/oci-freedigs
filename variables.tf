# OCI global

variable oci_region {
  default = "us-sanjose-1"
  # https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm
}

# OCI server default details

variable compute_hostname {
  default = "freedigs-compute-01"
  description = "The hostname that will be assigned to the main compute server of the oci-freedigs cluster"
}

variable compute_shape {
  default = "VM.Standard.A1.Flex"
}

variable compute_cores {
  default = "4"
}

variable compute_ram_gb {
  default = "24"
}

variable compute_disk_gb {
  default = "200"
}

# OCI lookups

variable "compute_image_ocid_map" {
  type = map(string)
  # https://docs.oracle.com/en-us/iaas/images/ubuntu-2004/
  # Ubuntu 20.04
  default = {
#    us-sanjose-1 = "ocid1.image.oc1.us-sanjose-1.aaaaaaaahdd7i2sp2yxu5skd72cefntfwizg7sop4bnzeziooavzmwyufynq"
    us-sanjose-1 = "ocid1.image.oc1.us-sanjose-1.aaaaaaaacdzh2e4tcrxowru2ygh62eiqp4iu2q2io3ippaqdtxks2ojtw5uq"
  }
}

variable "availability_domain_map" {
  type = map(string)
  default = {
    us-sanjose-1 = "Hrrb:US-SANJOSE-1-AD-1"
  }
}


# Secrets
# please configure in a file named something like "secrets.auto.tfvars"
# see the secrets.auto.tfvars.example for notes

variable tenancy_ocid {}
variable user_ocid {}
variable compartment_ocid {}
variable compute_username {}
variable compute_ssh_public_key {}
variable tailscale_auth_key {}
variable signing_key_fingerprint {}
variable signing_key_private_path {}
