resource oci_core_vcn freedigs_vcn_main {
  cidr_block     = "10.0.0.0/16"
  compartment_id = var.tenancy_ocid
  display_name   = "freedigs_vcn_main"
  dns_label      = "fdigsvcnmain"
}

resource oci_core_subnet freedigs_subnet_main {
  cidr_block     = "10.0.0.0/24"
  compartment_id = var.tenancy_ocid
  display_name   = "freedigs_subnet_main"
  dns_label      = "fdigssnetmain"
  vcn_id         = oci_core_vcn.freedigs_vcn_main.id
  route_table_id = oci_core_vcn.freedigs_vcn_main.default_route_table_id
}

resource oci_core_internet_gateway freedigs_gateway_main {
  compartment_id = var.tenancy_ocid
  display_name   = "freedigs_gateway_main"
  vcn_id         = oci_core_vcn.freedigs_vcn_main.id
}

resource oci_core_default_route_table freedigs_routes_main {
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.freedigs_gateway_main.id
  }
  manage_default_resource_id = oci_core_vcn.freedigs_vcn_main.default_route_table_id
}
