# OCI global

variable oci_region {
  default = "us-sanjose-1"
  # https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm
}

# OCI server default details

variable compute_os_label {
  default = "focal" # Ubuntu 20.04
}

variable compute_hosts {
  type = map(object({
    hostname = string
    arch = string
    cores = number
    ram_gb = number
    disk_gb = number
  }))
  default = {}
}

# OCI lookups

variable "compute_image_ocid_map" {
  type = map(string)
  # "focal" is Ubuntu 20.04 https://docs.oracle.com/en-us/iaas/images/ubuntu-2004/
  # key pattern is "region.arch.os"
  default = {
    "us-sanjose-1.amd64.focal" = "ocid1.image.oc1.us-sanjose-1.aaaaaaaahdd7i2sp2yxu5skd72cefntfwizg7sop4bnzeziooavzmwyufynq"
    "us-sanjose-1.aarch64.focal" = "ocid1.image.oc1.us-sanjose-1.aaaaaaaacdzh2e4tcrxowru2ygh62eiqp4iu2q2io3ippaqdtxks2ojtw5uq"
    "us-phoenix-1.amd64.focal" = "ocid1.image.oc1.phx.aaaaaaaazvmq762wkokwfxpec3iipkidzxrqxqv4bdmjszm4mkcno3nzzzga"
    "us-phoenix-1.aarch64.focal" = "ocid1.image.oc1.phx.aaaaaaaap6n3pdn4xiiyba6plfdq5nq5infnmkjm3nw7romlftpudjmro3ka"
  }
}

variable "availability_domain_map" {
  type = map(string)
  default = {}
}

variable "compute_shapes" {
  type = map(string)
  default = {
    aarch64 = "VM.Standard.A1.Flex"
    amd64 = "VM.Standard.E2.1.Micro"
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
variable cloudinit_script_url {}
